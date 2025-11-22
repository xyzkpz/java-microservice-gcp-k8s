# 🚀 Local Windows Deployment - Quick Start

## One-Command Deployment!

Just run this in PowerShell from the project directory:

```powershell
.\deploy-local.ps1
```

That's it! The script will:
- ✅ Check all prerequisites
- ✅ Build Docker image
- ✅ Deploy to Kubernetes
- ✅ Create all resources
- ✅ Test the application

---

## Manual Deployment (5 Steps)

### Prerequisites
Make sure you have:
1. **Docker Desktop** installed and running
2. **Kubernetes** enabled in Docker Desktop

### Step 1: Build Image
```powershell
docker build -t java-microservice:latest .
```

### Step 2: Deploy ConfigMap
```powershell
kubectl apply -f k8s/configmap.yaml
```

### Step 3: Deploy Application
```powershell
# Use the automated script to create local deployment files
.\deploy-local.ps1
```

OR manually create and apply files as shown in LOCAL_DEPLOYMENT_WINDOWS.md

### Step 4: Wait for Pods
```powershell
kubectl get pods -l app=java-microservice -w
```
Wait until you see `1/1 Running`

### Step 5: Access Application
Open browser to:
```
http://localhost:30080/
```

---

## Quick Test

```powershell
# Test all endpoints
curl http://localhost:30080/
curl http://localhost:30080/health
curl http://localhost:30080/config
```

---

## Troubleshooting

### Pods not starting?
```powershell
# Check Docker image exists
docker images | Select-String "java-microservice"

# Check pod status
kubectl describe pods -l app=java-microservice

# Check logs
kubectl logs -l app=java-microservice
```

### Can't access app?
```powershell
# Use port-forward instead
kubectl port-forward svc/java-microservice-service 8080:80
# Then access: http://localhost:8080/
```

---

## Stop Application

```powershell
kubectl delete -f k8s/service-local.yaml
kubectl delete -f k8s/deployment-local.yaml
kubectl delete -f k8s/configmap.yaml
```

---

## Full Documentation

- **Complete Guide:** LOCAL_DEPLOYMENT_WINDOWS.md
- **Checklist:** LOCAL_DEPLOYMENT_CHECKLIST.md
- **Automated Script:** deploy-local.ps1

---

**Need help?** Check LOCAL_DEPLOYMENT_WINDOWS.md for detailed troubleshooting!
