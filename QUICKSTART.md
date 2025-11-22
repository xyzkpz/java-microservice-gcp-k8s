# 🚀 Quick Start - 5 Minute Deployment

This guide will get your Java microservice running on GCP Kubernetes in just 5 steps!

## Before You Start

Make sure you have:
- ✅ GCP account with billing enabled
- ✅ `gcloud` CLI installed
- ✅ `kubectl` installed  
- ✅ `docker` installed

## Step-by-Step Deployment

### 1️⃣ Set Your GCP Project (30 seconds)

```bash
# Replace with YOUR project ID
export PROJECT_ID="your-gcp-project-id"

gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com containerregistry.googleapis.com
```

**Windows PowerShell:**
```powershell
$env:PROJECT_ID = "your-gcp-project-id"
gcloud config set project $env:PROJECT_ID
gcloud services enable container.googleapis.com containerregistry.googleapis.com
```

---

### 2️⃣ Create Kubernetes Cluster (5-10 minutes)

```bash
gcloud container clusters create java-microservice-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-medium

gcloud container clusters get-credentials java-microservice-cluster --zone=us-central1-a
```

**Windows PowerShell:**
```powershell
gcloud container clusters create java-microservice-cluster `
  --zone=us-central1-a `
  --num-nodes=3 `
  --machine-type=e2-medium

gcloud container clusters get-credentials java-microservice-cluster --zone=us-central1-a
```

> ⏱️ **This takes 5-10 minutes.** Grab a coffee! ☕

---

### 3️⃣ Build & Push Docker Image (3-5 minutes)

```bash
# Build the image
docker build -t gcr.io/$PROJECT_ID/java-microservice:latest .

# Authenticate Docker with GCR
gcloud auth configure-docker

# Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/java-microservice:latest
```

**Windows PowerShell:**
```powershell
docker build -t gcr.io/$env:PROJECT_ID/java-microservice:latest .
gcloud auth configure-docker
docker push gcr.io/$env:PROJECT_ID/java-microservice:latest
```

---

### 4️⃣ Update & Deploy (1 minute)

**Linux/Mac:**
```bash
# Update deployment with your PROJECT_ID
sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s/deployment.yaml

# Deploy to Kubernetes
kubectl apply -f k8s/
```

**Windows PowerShell:**
```powershell
# Update deployment with your PROJECT_ID
(Get-Content k8s/deployment.yaml) -replace 'YOUR_PROJECT_ID', $env:PROJECT_ID | Set-Content k8s/deployment.yaml

# Deploy to Kubernetes
kubectl apply -f k8s/
```

---

### 5️⃣ Get Your URL & Test (2-3 minutes)

```bash
# Watch for External IP (press Ctrl+C when IP appears)
kubectl get service java-microservice-service --watch
```

Once you see an IP address under `EXTERNAL-IP`:

```bash
# Get the IP
export EXTERNAL_IP=$(kubectl get service java-microservice-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test it!
curl http://$EXTERNAL_IP/
```

**Windows PowerShell:**
```powershell
$EXTERNAL_IP = kubectl get service java-microservice-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
curl http://$EXTERNAL_IP/
```

Or just open in your browser: `http://YOUR_EXTERNAL_IP/`

---

## 🎉 Success!

You should see a JSON response like:

```json
{
  "application": "Java Microservice on GCP",
  "version": "1.0.0",
  "environment": "production",
  "message": "Hello from GCP Kubernetes Cluster!",
  "timestamp": "2025-11-22T...",
  "status": "running"
}
```

## 📱 Test All Endpoints

```bash
# Home page
curl http://$EXTERNAL_IP/

# Health check
curl http://$EXTERNAL_IP/health

# View configuration (from ConfigMap)
curl http://$EXTERNAL_IP/config
```

---

## 🔧 Useful Commands

### View Your Pods
```bash
kubectl get pods -l app=java-microservice
```

### View Logs
```bash
kubectl logs -l app=java-microservice
```

### Scale Up/Down
```bash
kubectl scale deployment java-microservice --replicas=5
```

### Update ConfigMap
```bash
# Edit the config
kubectl edit configmap app-config

# Restart to apply changes
kubectl rollout restart deployment java-microservice
```

---

## 🛑 Stop & Clean Up

**When you're done testing:**

```bash
# Delete all Kubernetes resources
kubectl delete -f k8s/

# Delete the cluster
gcloud container clusters delete java-microservice-cluster --zone=us-central1-a
```

This will stop all charges!

---

## 📚 Need More Details?

- Full guide: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- Checklist: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
- All commands: [deploy-commands.sh](deploy-commands.sh) or [deploy-commands.ps1](deploy-commands.ps1)

---

## 🆘 Troubleshooting

### Pods not starting?
```bash
kubectl describe pods -l app=java-microservice
kubectl logs -l app=java-microservice
```

### External IP stuck on `<pending>`?
Wait 3-5 minutes. GCP takes time to provision the LoadBalancer.

### Can't access the URL?
1. Make sure External IP is assigned (not `<pending>`)
2. Check firewall rules in GCP Console
3. Try `curl` instead of browser

### Need help?
Check the full [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed troubleshooting.

---

## 💰 Cost Estimate

This setup costs approximately:
- **~$3-5 per day** (~$100-150/month)
- GKE cluster: 3 x e2-medium nodes
- LoadBalancer: Standard GCP LoadBalancer

💡 **Tip:** Delete the cluster when not using it to save costs!

---

**Happy Deploying! 🚀**
