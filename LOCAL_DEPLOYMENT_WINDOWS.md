# 🖥️ Local Windows Deployment Guide

Complete guide to deploy and run your Java microservice on your **Windows system** using Docker Desktop.

---

## 📋 Prerequisites

### **Required Software:**

1. **Docker Desktop for Windows**
   - Download: https://www.docker.com/products/docker-desktop/
   - Must have Kubernetes enabled
   
2. **Java 17 or higher** (Optional - for building without Docker)
   - Download: https://adoptium.net/
   
3. **Maven 3.6+** (Optional - for building without Docker)
   - Download: https://maven.apache.org/download.cgi
   
4. **Git** (Already installed if you cloned the repo)

---

## ⚙️ Step 1: Install and Configure Docker Desktop

### **1.1 Install Docker Desktop**

1. Download from: https://www.docker.com/products/docker-desktop/
2. Run the installer
3. Restart your computer when prompted

### **1.2 Enable Kubernetes in Docker Desktop**

1. Open **Docker Desktop**
2. Click **Settings** (gear icon)
3. Go to **Kubernetes** tab
4. Check **"Enable Kubernetes"**
5. Click **"Apply & Restart"**
6. Wait 2-3 minutes for Kubernetes to start

### **1.3 Verify Installation**

Open PowerShell and run:

```powershell
# Check Docker
docker --version
docker ps

# Check Kubernetes
kubectl version --client
kubectl get nodes
```

**Expected output:**
```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   1d    v1.28.x
```

---

## 🚀 Step 2: Clone Your Repository (If Not Already Done)

```powershell
# Navigate to your projects folder
cd C:\Users\kkish\.gemini\antigravity\scratch

# Clone repo (skip if already cloned)
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git

# Navigate into the project
cd java-microservice-gcp-k8s
```

---

## 🏗️ Step 3: Build the Docker Image

```powershell
# Build the Docker image
docker build -t java-microservice:latest .
```

**⏱️ This takes 3-5 minutes** (first time only - downloads Maven dependencies)

**Expected output:**
```
Successfully built xxxxxxxxx
Successfully tagged java-microservice:latest
```

### **Verify Image Was Built:**

```powershell
docker images | Select-String "java-microservice"
```

You should see:
```
java-microservice   latest   xxxxxxxxx   X minutes ago   450MB
```

---

## ☸️ Step 4: Create Local Kubernetes Manifests

### **4.1 Create ConfigMap**

```powershell
kubectl apply -f k8s/configmap.yaml
```

**Expected output:**
```
configmap/app-config created
```

### **4.2 Create Local Deployment File**

Create a deployment file optimized for local development:

```powershell
@"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-microservice
  labels:
    app: java-microservice
spec:
  replicas: 2
  selector:
    matchLabels:
      app: java-microservice
  template:
    metadata:
      labels:
        app: java-microservice
    spec:
      containers:
      - name: java-microservice
        image: java-microservice:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.name
        - name: APP_VERSION
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.version
        - name: APP_ENVIRONMENT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.environment
        - name: APP_MESSAGE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.message
        - name: SPRING_APPLICATION_JSON
          value: '{"app":{"name":"$$(APP_NAME)","version":"$$(APP_VERSION)","environment":"$$(APP_ENVIRONMENT)","message":"$$(APP_MESSAGE)"}}'
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
"@ | Out-File -FilePath k8s/deployment-local.yaml -Encoding utf8

kubectl apply -f k8s/deployment-local.yaml
```

**Expected output:**
```
deployment.apps/java-microservice created
```

### **4.3 Create NodePort Service**

```powershell
@"
apiVersion: v1
kind: Service
metadata:
  name: java-microservice-service
  labels:
    app: java-microservice
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
    protocol: TCP
    name: http
  selector:
    app: java-microservice
"@ | Out-File -FilePath k8s/service-local.yaml -Encoding utf8

kubectl apply -f k8s/service-local.yaml
```

**Expected output:**
```
service/java-microservice-service created
```

---

## ✅ Step 5: Verify Deployment

### **5.1 Check Pods**

```powershell
kubectl get pods -l app=java-microservice
```

**Wait until you see:**
```
NAME                                 READY   STATUS    RESTARTS   AGE
java-microservice-xxxxx-xxxxx        1/1     Running   0          1m
java-microservice-xxxxx-xxxxx        1/1     Running   0          1m
```

If pods show `0/1` or `ContainerCreating`, wait 30-60 seconds for the app to start.

### **5.2 Check Service**

```powershell
kubectl get service java-microservice-service
```

**Expected output:**
```
NAME                        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
java-microservice-service   NodePort   10.x.x.x        <none>        80:30080/TCP   1m
```

### **5.3 Check Logs**

```powershell
# Get logs from all pods
kubectl logs -l app=java-microservice --tail=50

# Or get specific pod logs
$podName = kubectl get pods -l app=java-microservice -o jsonpath="{.items[0].metadata.name}"
kubectl logs $podName
```

Look for:
```
Started Application in X.XXX seconds
```

---

## 🌐 Step 6: Access Your Application

### **Method 1: Using NodePort (Direct Access)**

Open your browser and go to:
```
http://localhost:30080/
```

Or use PowerShell:
```powershell
curl http://localhost:30080/
curl http://localhost:30080/health
curl http://localhost:30080/config
```

### **Method 2: Using Port Forward**

```powershell
kubectl port-forward svc/java-microservice-service 8080:80
```

Then access:
```
http://localhost:8080/
```

### **Expected Response:**

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

---

## 🧪 Step 7: Test All Endpoints

```powershell
# Home endpoint
Invoke-RestMethod -Uri http://localhost:30080/

# Health endpoint
Invoke-RestMethod -Uri http://localhost:30080/health

# Config endpoint (shows ConfigMap values)
Invoke-RestMethod -Uri http://localhost:30080/config

# Actuator health
Invoke-RestMethod -Uri http://localhost:30080/actuator/health
```

Or use curl:
```powershell
curl http://localhost:30080/
curl http://localhost:30080/health
curl http://localhost:30080/config
```

---

## 📊 Step 8: Monitor Your Application

### **View Logs**

```powershell
# Follow logs in real-time
kubectl logs -f -l app=java-microservice

# View recent logs
kubectl logs -l app=java-microservice --tail=100
```

### **Check Pod Status**

```powershell
# Watch pods
kubectl get pods -l app=java-microservice -w

# Describe pods
kubectl describe pods -l app=java-microservice
```

### **Check Resource Usage**

```powershell
kubectl top pods -l app=java-microservice
kubectl top nodes
```

---

## 🔧 Step 9: Common Operations

### **Scale Pods**

```powershell
# Scale to 3 replicas
kubectl scale deployment java-microservice --replicas=3

# Check scaling
kubectl get pods -l app=java-microservice
```

### **Update ConfigMap**

```powershell
# Edit ConfigMap
kubectl edit configmap app-config

# Restart deployment to pick up changes
kubectl rollout restart deployment java-microservice

# Wait for rollout
kubectl rollout status deployment java-microservice
```

### **Update Application Code**

```powershell
# 1. Make code changes in src/

# 2. Rebuild Docker image
docker build -t java-microservice:v2 .

# 3. Update deployment to use new version
kubectl set image deployment/java-microservice java-microservice=java-microservice:v2

# 4. Check rollout
kubectl rollout status deployment java-microservice
```

### **View Kubernetes Dashboard (Optional)**

```powershell
# Enable dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create admin user
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin

# Get token
kubectl -n kubernetes-dashboard create token dashboard-admin

# Start proxy
kubectl proxy

# Access at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

---

## 🧹 Step 10: Cleanup

### **Stop Pods (Keep Deployment)**

```powershell
kubectl scale deployment java-microservice --replicas=0
```

### **Delete Everything**

```powershell
# Delete all resources
kubectl delete -f k8s/service-local.yaml
kubectl delete -f k8s/deployment-local.yaml
kubectl delete -f k8s/configmap.yaml

# Or delete by label
kubectl delete all -l app=java-microservice
kubectl delete configmap app-config
```

### **Remove Docker Image**

```powershell
docker rmi java-microservice:latest
```

---

## 🐛 Troubleshooting

### **Issue: Pods stuck in Pending**

```powershell
# Check events
kubectl get events --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name>
```

**Common causes:**
- Not enough resources (close other apps)
- Kubernetes not enabled in Docker Desktop

---

### **Issue: Pods keep restarting**

```powershell
# Check logs
kubectl logs <pod-name> --previous

# Check pod description
kubectl describe pod <pod-name>
```

**Common causes:**
- Liveness probe failing (app taking too long to start)
- Out of memory

**Fix:** Increase resources or initialDelaySeconds

---

### **Issue: Can't access application**

```powershell
# Check if pods are running
kubectl get pods -l app=java-microservice

# Check service
kubectl get svc java-microservice-service

# Test from inside a pod
kubectl run curl-test --image=curlimages/curl -i --rm --restart=Never -- curl http://java-microservice-service/
```

**Fix:** Use port-forward instead:
```powershell
kubectl port-forward svc/java-microservice-service 8080:80
```

---

### **Issue: Docker build fails**

```powershell
# Clear Docker cache
docker system prune -a

# Rebuild
docker build --no-cache -t java-microservice:latest .
```

---

## 📈 Performance Tips

### **Increase Docker Resources**

1. Open **Docker Desktop**
2. Go to **Settings** > **Resources**
3. Increase:
   - **CPUs:** 4
   - **Memory:** 4GB
   - **Swap:** 1GB
4. Click **Apply & Restart**

### **Use Development Mode**

For faster rebuilds during development:

```powershell
# Build without cache
docker build --no-cache -t java-microservice:latest .

# Or use Maven directly (faster)
mvn clean package
docker build -t java-microservice:latest .
```

---

## 🎯 Quick Reference

### **Start Everything**

```powershell
cd java-microservice-gcp-k8s
docker build -t java-microservice:latest .
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment-local.yaml
kubectl apply -f k8s/service-local.yaml
kubectl get pods -w
```

### **Access App**

```
http://localhost:30080/
```

### **View Logs**

```powershell
kubectl logs -f -l app=java-microservice
```

### **Stop Everything**

```powershell
kubectl delete -f k8s/service-local.yaml
kubectl delete -f k8s/deployment-local.yaml
kubectl delete -f k8s/configmap.yaml
```

---

## ✅ Success Checklist

- [ ] Docker Desktop installed and running
- [ ] Kubernetes enabled in Docker Desktop
- [ ] Repository cloned
- [ ] Docker image built successfully
- [ ] ConfigMap created
- [ ] Deployment created with 2 pods running
- [ ] Service created  
- [ ] Can access http://localhost:30080/
- [ ] All endpoints return valid responses

---

## 🎉 You're Done!

Your Java microservice is now running locally on your Windows machine!

**Next steps:**
- Experiment with scaling
- Update ConfigMap values
- Modify code and redeploy
- When ready, deploy to GCP using DEPLOYMENT_GUIDE.md

---

**Need help?** Check the troubleshooting section or run diagnostic commands from the monitoring section.
