#!/bin/bash

# GCP Java Microservice Deployment - Quick Reference
# This script contains all the commands needed to deploy the Java microservice to GKE

# ============================================
# STEP 1: Configure GCP Project
# ============================================

# Set your GCP project ID (REPLACE with your actual project ID)
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"
export ZONE="us-central1-a"
export CLUSTER_NAME="java-microservice-cluster"

# Set the active project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com

# ============================================
# STEP 2: Create GKE Cluster
# ============================================

# Create a new GKE cluster (Takes 5-10 minutes)
gcloud container clusters create $CLUSTER_NAME \
  --zone=$ZONE \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --enable-autoscaling \
  --min-nodes=2 \
  --max-nodes=5 \
  --enable-autorepair \
  --enable-autoupgrade

# Get cluster credentials for kubectl
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# ============================================
# STEP 3: Build and Push Docker Image
# ============================================

# Build the Docker image
docker build -t gcr.io/$PROJECT_ID/java-microservice:latest .

# Configure Docker authentication for GCR
gcloud auth configure-docker

# Push image to Google Container Registry
docker push gcr.io/$PROJECT_ID/java-microservice:latest

# Verify image is in GCR
gcloud container images list
gcloud container images describe gcr.io/$PROJECT_ID/java-microservice:latest

# ============================================
# STEP 4: Update Kubernetes Manifests
# ============================================

# Update deployment.yaml with your PROJECT_ID
# On Linux/Mac:
sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s/deployment.yaml

# On Windows PowerShell:
# (Get-Content k8s/deployment.yaml) -replace 'YOUR_PROJECT_ID', $env:PROJECT_ID | Set-Content k8s/deployment.yaml

# ============================================
# STEP 5: Deploy to Kubernetes
# ============================================

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Apply Deployment
kubectl apply -f k8s/deployment.yaml

# Apply Service (LoadBalancer)
kubectl apply -f k8s/service.yaml

# ============================================
# STEP 6: Verify Deployment
# ============================================

# Check all resources
kubectl get all

# Check ConfigMap
kubectl get configmap app-config
kubectl describe configmap app-config

# Check Deployment
kubectl get deployment java-microservice
kubectl describe deployment java-microservice

# Check Pods
kubectl get pods -l app=java-microservice
kubectl describe pods -l app=java-microservice

# Check Service and wait for External IP
kubectl get service java-microservice-service
kubectl get service java-microservice-service --watch

# ============================================
# STEP 7: Get External IP and Test
# ============================================

# Get the external IP (wait until it's not <pending>)
export EXTERNAL_IP=$(kubectl get service java-microservice-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "External IP: $EXTERNAL_IP"

# Test the endpoints
curl http://$EXTERNAL_IP/
curl http://$EXTERNAL_IP/health
curl http://$EXTERNAL_IP/config

# Or open in browser
echo "Open in browser: http://$EXTERNAL_IP/"

# ============================================
# MONITORING AND LOGS
# ============================================

# View logs for all pods
kubectl logs -l app=java-microservice --all-containers=true

# View logs for specific pod
POD_NAME=$(kubectl get pods -l app=java-microservice -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME

# Follow logs
kubectl logs -f $POD_NAME

# Execute commands inside a pod
kubectl exec -it $POD_NAME -- /bin/sh

# ============================================
# SCALING
# ============================================

# Manual scaling
kubectl scale deployment java-microservice --replicas=5

# Enable horizontal pod autoscaling
kubectl autoscale deployment java-microservice \
  --cpu-percent=70 \
  --min=3 \
  --max=10

# Check HPA status
kubectl get hpa

# ============================================
# UPDATING APPLICATION
# ============================================

# Update ConfigMap
kubectl edit configmap app-config
# OR
kubectl apply -f k8s/configmap.yaml

# Restart deployment to pick up config changes
kubectl rollout restart deployment java-microservice

# Update application code (build new version)
docker build -t gcr.io/$PROJECT_ID/java-microservice:v2 .
docker push gcr.io/$PROJECT_ID/java-microservice:v2

# Update deployment to use new image
kubectl set image deployment/java-microservice \
  java-microservice=gcr.io/$PROJECT_ID/java-microservice:v2

# Check rollout status
kubectl rollout status deployment/java-microservice

# Rollback if needed
kubectl rollout undo deployment/java-microservice

# ============================================
# TROUBLESHOOTING
# ============================================

# Check pod status
kubectl get pods -l app=java-microservice

# Describe a failing pod
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# View previous container logs (if crashed)
kubectl logs <pod-name> --previous

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check service endpoints
kubectl get endpoints java-microservice-service

# ============================================
# CLEANUP (When done testing)
# ============================================

# Delete Kubernetes resources
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/configmap.yaml

# Or delete everything at once
kubectl delete -f k8s/

# Delete the GKE cluster
gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE

# Delete Docker images from GCR (optional)
gcloud container images delete gcr.io/$PROJECT_ID/java-microservice:latest --quiet

# ============================================
# USEFUL COMMANDS
# ============================================

# List all clusters
gcloud container clusters list

# Resize cluster
gcloud container clusters resize $CLUSTER_NAME --num-nodes=5 --zone=$ZONE

# Get cluster credentials
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

# View cluster details
gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE

# List all GCR images
gcloud container images list

# View kubectl config
kubectl config view
kubectl config get-contexts
kubectl config current-context

# Switch context
kubectl config use-context <context-name>

# Port forward for local testing (useful for debugging)
kubectl port-forward svc/java-microservice-service 8080:80

echo "Deployment complete! Access your application at http://$EXTERNAL_IP/"
