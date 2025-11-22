# Pre-Deployment Checklist

## Prerequisites
- [ ] Google Cloud account created and billing enabled
- [ ] gcloud CLI installed and authenticated (`gcloud auth login`)
- [ ] Docker installed and running
- [ ] kubectl installed
- [ ] Java 17 or higher installed (for local testing)
- [ ] Maven 3.6+ installed (for local testing)

## GCP Setup
- [ ] GCP Project created
- [ ] Project ID noted down: `________________`
- [ ] Required APIs enabled:
  - [ ] Kubernetes Engine API
  - [ ] Container Registry API

## Configuration
- [ ] Updated `PROJECT_ID` in deployment scripts
- [ ] Updated `k8s/deployment.yaml` with your PROJECT_ID
- [ ] Reviewed and customized `k8s/configmap.yaml` values

## Deployment Steps

### Step 1: GCP Project Configuration
- [ ] Set active GCP project
- [ ] Enable Container Registry and Kubernetes Engine APIs
- [ ] Choose region and zone (default: us-central1-a)

### Step 2: Create GKE Cluster
- [ ] Run cluster creation command
- [ ] Wait 5-10 minutes for cluster creation
- [ ] Verify cluster is running with `kubectl get nodes`
- [ ] Confirm 3 nodes are in "Ready" state

### Step 3: Build Docker Image
- [ ] Navigate to project directory
- [ ] Run `docker build` command
- [ ] Verify image is built successfully
- [ ] Configure Docker authentication for GCR
- [ ] Push image to Google Container Registry
- [ ] Verify image in GCR

### Step 4: Update Kubernetes Manifests
- [ ] Open `k8s/deployment.yaml`
- [ ] Replace `YOUR_PROJECT_ID` with actual project ID
- [ ] Save the file

### Step 5: Deploy to Kubernetes
- [ ] Apply ConfigMap: `kubectl apply -f k8s/configmap.yaml`
- [ ] Apply Deployment: `kubectl apply -f k8s/deployment.yaml`
- [ ] Apply Service: `kubectl apply -f k8s/service.yaml`

### Step 6: Verify Deployment
- [ ] Check ConfigMap exists
- [ ] Check Deployment status (should show 3/3 replicas)
- [ ] Check all Pods are running (may take 2-3 minutes)
- [ ] Check Service is created
- [ ] Wait for External IP assignment (2-5 minutes)
- [ ] Note External IP: `________________`

### Step 7: Test Application
- [ ] Access `http://EXTERNAL_IP/` in browser
- [ ] Test `/health` endpoint
- [ ] Test `/config` endpoint to verify ConfigMap values
- [ ] Verify response shows correct configuration

### Step 8: Verify Logs
- [ ] View pod logs
- [ ] Check for any errors or warnings
- [ ] Verify application started successfully

## Post-Deployment Verification

### Health Checks
- [ ] All pods are in "Running" state
- [ ] Liveness probes are passing
- [ ] Readiness probes are passing
- [ ] No pod restarts or crashes

### Networking
- [ ] LoadBalancer has external IP assigned
- [ ] Can access application from browser on port 80
- [ ] All endpoints responding correctly

### Configuration
- [ ] ConfigMap values are being read by application
- [ ] Application displays correct environment settings

## Optional Advanced Steps
- [ ] Set up Horizontal Pod Autoscaling
- [ ] Configure Cloud Monitoring
- [ ] Set up Cloud Logging
- [ ] Configure custom domain with Cloud DNS
- [ ] Set up SSL/TLS with Ingress
- [ ] Implement CI/CD pipeline
- [ ] Set up backup and disaster recovery

## Common Issues Checklist

### If pods are not starting:
- [ ] Check pod logs: `kubectl logs <pod-name>`
- [ ] Check pod description: `kubectl describe pod <pod-name>`
- [ ] Verify image exists in GCR
- [ ] Check resource quotas

### If External IP is pending:
- [ ] Wait 5 minutes (can take time)
- [ ] Check service description: `kubectl describe svc java-microservice-service`
- [ ] Verify LoadBalancer is being created in GCP Console

### If cannot access application:
- [ ] Verify External IP is assigned
- [ ] Check firewall rules in GCP
- [ ] Verify service selector matches pod labels
- [ ] Test with curl instead of browser

## Cost Management
- [ ] Understand cluster running costs (~$100-200/month for this setup)
- [ ] Set up billing alerts
- [ ] Stop/delete cluster when not in use
- [ ] Consider using preemptible nodes for dev/test

## Cleanup Checklist
When you're done:
- [ ] Delete Kubernetes resources
- [ ] Delete GKE cluster
- [ ] Delete container images from GCR (optional)
- [ ] Verify cluster is deleted in GCP Console
- [ ] Check billing to ensure resources are deleted

## Notes

### Important Information:
- Cluster Name: `________________`
- External IP: `________________`
- Region/Zone: `________________`
- Estimated Cost: `$________/month`

### Useful Commands:
```bash
# Quick status check
kubectl get all

# View external IP
kubectl get svc java-microservice-service

# View logs
kubectl logs -l app=java-microservice

# Scale pods
kubectl scale deployment java-microservice --replicas=5
```

---

**Deployment Date:** ___________  
**Deployed By:** ___________  
**Status:** ☐ Success ☐ Failed  
**Notes:** ________________________________
