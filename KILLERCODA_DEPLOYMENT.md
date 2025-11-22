# 🚀 Killercoda Deployment Guide

## Step-by-Step Guide to Deploy Your Java Microservice on Killercoda

---

## 📋 Pre-Deployment Setup

### **Important Notes:**
- Killercoda doesn't support LoadBalancer type services
- We'll use **NodePort** instead to access the application
- Docker images will be built locally in the cluster
- Session may expire after inactivity

---

## 🎯 Deployment Steps

### **Step 1: Access Killercoda Kubernetes Playground**

1. Go to: https://killercoda.com/playgrounds/scenario/kubernetes
2. Click **"Start"** button
3. Wait for the environment to load (30-60 seconds)
4. You'll see a terminal on the right side

---

### **Step 2: Verify Kubernetes Cluster**

In the Killercoda terminal, run:

```bash
kubectl get nodes
```

**Expected Output:**
```
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   1m    v1.28.x
node01         Ready    <none>          1m    v1.28.x
```

✅ You should see 2 nodes in "Ready" status

---

### **Step 3: Clone Your Repository**

```bash
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git
cd java-microservice-gcp-k8s
```

---

### **Step 4: Build Docker Image Locally**

Since we can't push to GCR from Killercoda, we'll build the image locally:

```bash
# Build the Docker image
docker build -t java-microservice:latest .

# Verify the image was built
docker images | grep java-microservice
```

**Expected Output:**
```
java-microservice   latest   <image-id>   X seconds ago   XXX MB
```

---

### **Step 5: Create Modified Kubernetes Manifests for Killercoda**

#### **5.1 Apply ConfigMap (No changes needed)**

```bash
kubectl apply -f k8s/configmap.yaml
```

**Expected Output:**
```
configmap/app-config created
```

---

#### **5.2 Create Modified Deployment**

We need to update the image reference since we built it locally:

```bash
# Create a modified deployment file
cat > k8s/deployment-killercoda.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-microservice
  namespace: default
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
          value: '{"app":{"name":"$(APP_NAME)","version":"$(APP_VERSION)","environment":"$(APP_ENVIRONMENT)","message":"$(APP_MESSAGE)"}}'
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
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
EOF

# Apply the modified deployment
kubectl apply -f k8s/deployment-killercoda.yaml
```

**Expected Output:**
```
deployment.apps/java-microservice created
```

---

#### **5.3 Create NodePort Service**

Since LoadBalancer doesn't work in Killercoda, we'll use NodePort:

```bash
# Create a NodePort service
cat > k8s/service-killercoda.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: java-microservice-service
  namespace: default
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
EOF

# Apply the service
kubectl apply -f k8s/service-killercoda.yaml
```

**Expected Output:**
```
service/java-microservice-service created
```

---

### **Step 6: Verify Deployment**

#### **6.1 Check Pods**

```bash
kubectl get pods -l app=java-microservice
```

**Expected Output:**
```
NAME                                 READY   STATUS    RESTARTS   AGE
java-microservice-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
java-microservice-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
```

Wait until all pods show **"Running"** status and **"1/1"** ready.

If pods are not ready yet, wait 1-2 minutes for the application to start.

---

#### **6.2 Check Service**

```bash
kubectl get service java-microservice-service
```

**Expected Output:**
```
NAME                        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
java-microservice-service   NodePort   10.x.x.x       <none>        80:30080/TCP   1m
```

---

#### **6.3 Check Logs**

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=java-microservice -o jsonpath='{.items[0].metadata.name}')

# View logs
kubectl logs $POD_NAME
```

You should see Spring Boot startup logs.

---

### **Step 7: Access Your Application**

Since we're using NodePort, we can access the app in multiple ways:

#### **Method 1: Using Port Forward (Recommended)**

```bash
kubectl port-forward svc/java-microservice-service 8080:80
```

Then in **Killercoda**, look for the **port access buttons** at the top of the page. Click on port **8080**.

Or use curl in another terminal tab:
```bash
curl http://localhost:8080/
```

---

#### **Method 2: Using NodePort**

```bash
# Get the node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Access the service
curl http://$NODE_IP:30080/
```

---

#### **Method 3: Using Cluster IP (from within the cluster)**

```bash
# Get cluster IP
CLUSTER_IP=$(kubectl get svc java-microservice-service -o jsonpath='{.spec.clusterIP}')

# Access using curl
curl http://$CLUSTER_IP/
```

---

### **Step 8: Test All Endpoints**

Once you have access, test all endpoints:

```bash
# Home endpoint
curl http://localhost:8080/

# Health endpoint
curl http://localhost:8080/health

# Config endpoint (shows ConfigMap values)
curl http://localhost:8080/config

# Actuator health
curl http://localhost:8080/actuator/health
```

**Expected Response (Home endpoint):**
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

## 🎯 Quick Commands Summary

```bash
# 1. Clone repo
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git
cd java-microservice-gcp-k8s

# 2. Build Docker image
docker build -t java-microservice:latest .

# 3. Deploy to Kubernetes
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment-killercoda.yaml
kubectl apply -f k8s/service-killercoda.yaml

# 4. Check status
kubectl get pods -l app=java-microservice
kubectl get svc java-microservice-service

# 5. Access application
kubectl port-forward svc/java-microservice-service 8080:80
# Then access via Killercoda's port 8080 button

# 6. Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/config
```

---

## 📊 Monitoring & Debugging

### **View Logs**
```bash
# Get all pod logs
kubectl logs -l app=java-microservice --all-containers=true

# Follow logs for specific pod
kubectl logs -f <pod-name>

# Get recent logs
kubectl logs --tail=50 <pod-name>
```

### **Describe Resources**
```bash
# Describe deployment
kubectl describe deployment java-microservice

# Describe pod
kubectl describe pod <pod-name>

# Describe service
kubectl describe svc java-microservice-service
```

### **Get Events**
```bash
kubectl get events --sort-by='.lastTimestamp'
```

### **Check Resource Usage**
```bash
kubectl top pods
kubectl top nodes
```

---

## 🔧 Common Issues & Solutions

### **Issue 1: Pods stuck in "Pending" or "ContainerCreating"**

**Solution:**
```bash
# Check pod description
kubectl describe pod <pod-name>

# Common cause: Image pull issues (should use imagePullPolicy: Never)
# Common cause: Insufficient resources
```

---

### **Issue 2: Pods keep restarting**

**Solution:**
```bash
# Check logs
kubectl logs <pod-name> --previous

# Common cause: Application crash
# Common cause: Liveness probe failing (increase initialDelaySeconds)
```

---

### **Issue 3: Can't access application**

**Solution:**
```bash
# 1. Use port-forward instead of NodePort
kubectl port-forward svc/java-microservice-service 8080:80

# 2. Access from within a pod
kubectl run curl-test --image=curlimages/curl -i --rm --restart=Never -- curl http://java-microservice-service/
```

---

### **Issue 4: Docker build fails**

**Solution:**
```bash
# Check Docker is running
docker ps

# Build with verbose output
docker build -t java-microservice:latest . --progress=plain

# If Maven fails, you might need to wait longer or build locally first
```

---

## 🎨 Customize Configuration

### **Update ConfigMap Values**

```bash
# Edit ConfigMap
kubectl edit configmap app-config

# Or apply updated file
kubectl apply -f k8s/configmap.yaml

# Restart deployment to pick up changes
kubectl rollout restart deployment java-microservice

# Check rollout status
kubectl rollout status deployment java-microservice
```

---

## 🧹 Cleanup

When you're done testing:

```bash
# Delete all resources
kubectl delete -f k8s/service-killercoda.yaml
kubectl delete -f k8s/deployment-killercoda.yaml
kubectl delete -f k8s/configmap.yaml

# Or delete by label
kubectl delete all -l app=java-microservice
kubectl delete configmap app-config
```

---

## ✅ Success Checklist

- [ ] Kubernetes cluster is running (2 nodes ready)
- [ ] Repository cloned successfully
- [ ] Docker image built successfully
- [ ] ConfigMap created
- [ ] Deployment created with 2 pods running
- [ ] Service created with NodePort
- [ ] Can access application via port-forward
- [ ] All endpoints return valid JSON responses
- [ ] ConfigMap values are displayed correctly in `/config` endpoint

---

## 🎉 Congratulations!

You've successfully deployed your Java microservice on Killercoda Kubernetes playground!

**What's Next?**
- Experiment with scaling: `kubectl scale deployment java-microservice --replicas=3`
- Update ConfigMap and restart pods
- Try different Kubernetes features
- When ready, deploy to real GCP with the full DEPLOYMENT_GUIDE.md

---

**Need Help?** Check the troubleshooting section above or examine pod logs for errors.
