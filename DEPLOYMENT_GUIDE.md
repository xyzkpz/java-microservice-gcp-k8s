# Java Microservice Deployment to GCP Kubernetes

This guide provides step-by-step instructions to deploy a Java microservice to Google Kubernetes Engine (GKE) with ConfigMap and LoadBalancer access on port 80.

## Prerequisites

1. **Google Cloud Account** with billing enabled
2. **Google Cloud SDK (gcloud)** installed and configured
3. **Docker** installed locally
4. **kubectl** installed
5. **Java 17** and **Maven** (for local testing)

## Project Structure

```
java-k8s-gcp-deployment/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/
│       │       ├── Application.java
│       │       └── controller/
│       │           └── HealthController.java
│       └── resources/
│           └── application.properties
├── k8s/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
├── pom.xml
└── DEPLOYMENT_GUIDE.md
```

## Step 1: Set Up GCP Project

```bash
# Set your GCP project ID
export PROJECT_ID="your-gcp-project-id"

# Set the project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

## Step 2: Create GKE Cluster

```bash
# Set your preferred region and zone
export REGION="us-central1"
export ZONE="us-central1-a"

# Create a GKE cluster (this may take 5-10 minutes)
gcloud container clusters create java-microservice-cluster \
  --zone=$ZONE \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --enable-autoscaling \
  --min-nodes=2 \
  --max-nodes=5 \
  --enable-autorepair \
  --enable-autoupgrade

# Get credentials for kubectl
gcloud container clusters get-credentials java-microservice-cluster --zone=$ZONE
```

## Step 3: Build and Push Docker Image

```bash
# Navigate to the project directory
cd java-k8s-gcp-deployment

# Build the Docker image
docker build -t gcr.io/$PROJECT_ID/java-microservice:latest .

# Configure Docker to use gcloud as a credential helper
gcloud auth configure-docker

# Push the image to Google Container Registry
docker push gcr.io/$PROJECT_ID/java-microservice:latest

# Verify the image is in GCR
gcloud container images list
```

## Step 4: Update Kubernetes Manifests

Before deploying, update the `k8s/deployment.yaml` file:

1. Replace `YOUR_PROJECT_ID` with your actual GCP project ID:
   ```yaml
   image: gcr.io/YOUR_PROJECT_ID/java-microservice:latest
   ```

You can do this with:
```bash
# Replace YOUR_PROJECT_ID in deployment.yaml
sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s/deployment.yaml
```

On Windows PowerShell:
```powershell
(Get-Content k8s/deployment.yaml) -replace 'YOUR_PROJECT_ID', $env:PROJECT_ID | Set-Content k8s/deployment.yaml
```

## Step 5: Deploy to Kubernetes

```bash
# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Apply Deployment
kubectl apply -f k8s/deployment.yaml

# Apply Service (LoadBalancer)
kubectl apply -f k8s/service.yaml
```

## Step 6: Verify Deployment

```bash
# Check ConfigMap
kubectl get configmap app-config

# Check Deployment
kubectl get deployment java-microservice

# Check Pods
kubectl get pods -l app=java-microservice

# Check Service and get External IP (may take 2-3 minutes)
kubectl get service java-microservice-service

# Watch for External IP to be assigned
kubectl get service java-microservice-service --watch
```

Wait until you see an EXTERNAL-IP (it will say `<pending>` initially).

## Step 7: Test the Application

Once the EXTERNAL-IP is assigned:

```bash
# Get the external IP
export EXTERNAL_IP=$(kubectl get service java-microservice-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test the home endpoint
curl http://$EXTERNAL_IP/

# Test the health endpoint
curl http://$EXTERNAL_IP/health

# Test the config endpoint (to see ConfigMap values)
curl http://$EXTERNAL_IP/config
```

Or open in your browser:
- `http://EXTERNAL_IP/`
- `http://EXTERNAL_IP/health`
- `http://EXTERNAL_IP/config`

## Step 8: View Logs

```bash
# Get pod name
kubectl get pods -l app=java-microservice

# View logs for a specific pod
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# View logs for all pods
kubectl logs -l app=java-microservice --all-containers=true
```

## Updating the Application

### Update ConfigMap

```bash
# Edit the ConfigMap
kubectl edit configmap app-config

# Or apply updated configmap.yaml
kubectl apply -f k8s/configmap.yaml

# Restart pods to pick up new config
kubectl rollout restart deployment java-microservice
```

### Update Application Code

```bash
# Build new image with a version tag
docker build -t gcr.io/$PROJECT_ID/java-microservice:v2 .

# Push to GCR
docker push gcr.io/$PROJECT_ID/java-microservice:v2

# Update deployment to use new image
kubectl set image deployment/java-microservice \
  java-microservice=gcr.io/$PROJECT_ID/java-microservice:v2

# Check rollout status
kubectl rollout status deployment/java-microservice
```

## Scaling the Application

```bash
# Scale to 5 replicas
kubectl scale deployment java-microservice --replicas=5

# Enable horizontal pod autoscaling
kubectl autoscale deployment java-microservice \
  --cpu-percent=70 \
  --min=3 \
  --max=10

# Check autoscaler status
kubectl get hpa
```

## Monitoring and Debugging

```bash
# Describe deployment
kubectl describe deployment java-microservice

# Describe service
kubectl describe service java-microservice-service

# Get pod details
kubectl describe pod <pod-name>

# Execute commands in a pod
kubectl exec -it <pod-name> -- /bin/sh

# Check cluster info
kubectl cluster-info

# View all resources
kubectl get all
```

## Clean Up Resources

When you're done testing:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/configmap.yaml

# Delete GKE cluster
gcloud container clusters delete java-microservice-cluster --zone=$ZONE

# Delete Docker images from GCR (optional)
gcloud container images delete gcr.io/$PROJECT_ID/java-microservice:latest --quiet
```

## Cost Optimization Tips

1. **Use smaller machine types** for development: `e2-small` or `e2-micro`
2. **Enable cluster autoscaling** to scale down when not in use
3. **Stop/delete the cluster** when not actively using it
4. **Use preemptible nodes** for non-production workloads (60-91% cheaper)
5. **Set resource limits** in deployment.yaml to optimize pod scheduling

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Service not getting External IP
```bash
# Check service events
kubectl describe service java-microservice-service

# Verify service type is LoadBalancer
kubectl get service java-microservice-service -o yaml
```

### ConfigMap values not applied
```bash
# Verify ConfigMap exists
kubectl get configmap app-config -o yaml

# Restart pods
kubectl rollout restart deployment java-microservice
```

### Cannot access application
```bash
# Check firewall rules
gcloud compute firewall-rules list

# Verify LoadBalancer is created
kubectl get svc java-microservice-service
```

## Security Best Practices

1. **Use private GKE clusters** for production
2. **Enable Workload Identity** for secure access to GCP services
3. **Use secrets** for sensitive data instead of ConfigMaps
4. **Enable network policies** to control pod-to-pod communication
5. **Regularly update** cluster and node versions
6. **Use RBAC** for access control
7. **Enable audit logging**

## Next Steps

- Set up CI/CD pipeline with Cloud Build or Jenkins
- Add Ingress for SSL/TLS termination
- Implement monitoring with Cloud Monitoring/Prometheus
- Add logging with Cloud Logging/ELK stack
- Implement secrets management with Secret Manager
- Add database connectivity
- Implement service mesh (Istio/Anthos Service Mesh)

## Support

For issues, refer to:
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
