# ✅ Local Windows Deployment Checklist

Use this checklist to track your local deployment progress.

---

## 📋 Pre-Deployment Checklist

### **Software Installation**
- [ ] Docker Desktop installed
- [ ] Docker Desktop is running
- [ ] Kubernetes enabled in Docker Desktop (Settings > Kubernetes)
- [ ] Kubernetes is running (green indicator in Docker Desktop)
- [ ] Git installed (to clone repo)
- [ ] PowerShell or Command Prompt available

### **Verify Installation**
- [ ] Run `docker --version` - shows version
- [ ] Run `docker ps` - shows running containers
- [ ] Run `kubectl version --client` - shows version
- [ ] Run `kubectl get nodes` - shows `docker-desktop` node in Ready status

---

## 🚀 Deployment Steps

### **Step 1: Get the Code**
- [ ] Navigated to projects directory
- [ ] Cloned repository: `git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git`
- [ ] Changed into directory: `cd java-microservice-gcp-k8s`
- [ ] Verified files exist: `ls` or `dir`

### **Step 2: Build Docker Image**
- [ ] Started Docker Desktop
- [ ] Ran: `docker build -t java-microservice:latest .`
- [ ] Build completed successfully (no errors)
- [ ] Build time: _____ minutes
- [ ] Verified image: `docker images | Select-String "java-microservice"`
- [ ] Image size: _____ MB

### **Step 3: Deploy to Kubernetes**

#### **3.1 Create ConfigMap**
- [ ] Ran: `kubectl apply -f k8s/configmap.yaml`
- [ ] Output: `configmap/app-config created`
- [ ] Verified: `kubectl get configmap app-config`

#### **3.2 Create Deployment**
- [ ] Created `k8s/deployment-local.yaml` file
- [ ] Ran: `kubectl apply -f k8s/deployment-local.yaml`
- [ ] Output: `deployment.apps/java-microservice created`
- [ ] Waited 30-60 seconds for pods to start

#### **3.3 Create Service**
- [ ] Created `k8s/service-local.yaml` file
- [ ] Ran: `kubectl apply -f k8s/service-local.yaml`
- [ ] Output: `service/java-microservice-service created`

### **Step 4: Verify Deployment**

#### **4.1 Check Pods**
- [ ] Ran: `kubectl get pods -l app=java-microservice`
- [ ] Pods show `1/1 Running` status
- [ ] Both pods are ready (not pending/crashing)
- [ ] Pod names noted: 
  - `____________________________________`
  - `____________________________________`

#### **4.2 Check Service**
- [ ] Ran: `kubectl get service java-microservice-service`
- [ ] Service type: NodePort
- [ ] ClusterIP assigned: `____________`
- [ ] NodePort: 30080

#### **4.3 Check Logs**
- [ ] Ran: `kubectl logs -l app=java-microservice --tail=50`
- [ ] Logs show: "Started Application in X.XXX seconds"
- [ ] No error messages in logs

### **Step 5: Access Application**

#### **5.1 Test Endpoints**
- [ ] Opened browser to: `http://localhost:30080/`
- [ ] Home endpoint returns JSON response
- [ ] Tested: `http://localhost:30080/health` - returns `{"status":"UP"}`
- [ ] Tested: `http://localhost:30080/config` - shows ConfigMap values
- [ ] Tested: `http://localhost:30080/actuator/health` - shows detailed health

#### **5.2 Verify Responses**
- [ ] Application name displayed correctly
- [ ] Version shows: 1.0.0
- [ ] Environment shows ConfigMap value
- [ ] Custom message displays
- [ ] Timestamp is current

### **Step 6: Testing & Validation**

#### **6.1 Functional Tests**
- [ ] All API endpoints respond
- [ ] Response times acceptable (< 1 second)
- [ ] No 500 errors
- [ ] ConfigMap integration working

#### **6.2 Scale Test**
- [ ] Scaled to 3 replicas: `kubectl scale deployment java-microservice --replicas=3`
- [ ] All 3 pods running
- [ ] Application still accessible
- [ ] Scaled back to 2: `kubectl scale deployment java-microservice --replicas=2`

#### **6.3 Update Test**
- [ ] Updated ConfigMap values
- [ ] Restarted deployment: `kubectl rollout restart deployment java-microservice`
- [ ] Verified new values at `/config` endpoint

---

## 📊 Deployment Information

### **Environment Details**
- **Deployment Date:** _______________
- **Deployed By:** _______________
- **Docker Desktop Version:** _______________
- **Kubernetes Version:** _______________

### **Resource Details**
- **Number of Pods:** 2
- **CPU Request per Pod:** 100m
- **Memory Request per Pod:** 256Mi
- **CPU Limit per Pod:** 500m
- **Memory Limit per Pod:** 512Mi

### **Access Information**
- **Local URL:** http://localhost:30080/
- **Service Name:** java-microservice-service
- **Service Type:** NodePort
- **Port Mapping:** 80:30080

---

## 🔍 Monitoring Checklist

### **Daily Checks**
- [ ] Pods are running: `kubectl get pods -l app=java-microservice`
- [ ] No pod restarts
- [ ] Application accessible
- [ ] Logs show no errors

### **Health Checks**
- [ ] Liveness probe passing
- [ ] Readiness probe passing
- [ ] `/health` endpoint returns 200 OK
- [ ] `/actuator/health` shows all components UP

---

## 🐛 Troubleshooting Checklist

### **If Pods Not Starting**
- [ ] Checked Docker is running
- [ ] Checked Kubernetes is enabled
- [ ] Ran: `kubectl describe pod <pod-name>`
- [ ] Checked events: `kubectl get events --sort-by='.lastTimestamp'`
- [ ] Verified Docker image exists: `docker images | Select-String "java-microservice"`
- [ ] Checked pod logs: `kubectl logs <pod-name>`

### **If Can't Access Application**
- [ ] Verified pods are running
- [ ] Verified service exists: `kubectl get svc`
- [ ] Tried NodePort: `http://localhost:30080/`
- [ ] Tried port-forward: `kubectl port-forward svc/java-microservice-service 8080:80`
- [ ] Checked firewall settings
- [ ] Tested from inside pod: `kubectl run curl-test --image=curlimages/curl -i --rm -- curl http://java-microservice-service/`

### **If Pods Crashing**
- [ ] Checked logs: `kubectl logs <pod-name> --previous`
- [ ] Checked resource limits
- [ ] Increased liveness/readiness probe delays
- [ ] Verified ConfigMap exists
- [ ] Checked for out-of-memory errors

---

## 🧹 Cleanup Checklist

### **Stop Application (Keep Resources)**
- [ ] Scaled to 0: `kubectl scale deployment java-microservice --replicas=0`

### **Delete All Resources**
- [ ] Deleted service: `kubectl delete -f k8s/service-local.yaml`
- [ ] Deleted deployment: `kubectl delete -f k8s/deployment-local.yaml`
- [ ] Deleted configmap: `kubectl delete -f k8s/configmap.yaml`
- [ ] Verified deletion: `kubectl get all -l app=java-microservice`

### **Clean Docker Images**
- [ ] Removed image: `docker rmi java-microservice:latest`
- [ ] Cleaned system: `docker system prune`

---

## ✅ Success Criteria

### **Deployment is Successful When:**
- [x] All pods show `1/1 Running` status
- [x] Service has ClusterIP assigned
- [x] Application accessible at `http://localhost:30080/`
- [x] All endpoints return valid JSON
- [x] No errors in logs
- [x] ConfigMap values displayed correctly
- [x] Health checks passing
- [x] Can scale up and down
- [x] Can update and rollout changes

---

## 📝 Notes & Issues

### **Issues Encountered:**
```
Issue 1: ________________________________________________
Solution: ________________________________________________

Issue 2: ________________________________________________
Solution: ________________________________________________

Issue 3: ________________________________________________
Solution: ________________________________________________
```

### **Performance Notes:**
```
Docker build time: _______ minutes
Pod startup time: _______ seconds
Average response time: _______ ms
```

### **Custom Modifications:**
```
List any changes made to configuration:
- ________________________________________________
- ________________________________________________
- ________________________________________________
```

---

## 🎯 Next Steps

After successful local deployment:
- [ ] Test scaling to different replica counts
- [ ] Experiment with ConfigMap updates
- [ ] Try modifying application code and redeploying
- [ ] Set up port-forwarding for different ports
- [ ] Explore Kubernetes dashboard
- [ ] When ready, deploy to GCP using `DEPLOYMENT_GUIDE.md`
- [ ] Set up CI/CD pipeline
- [ ] Add monitoring and alerting

---

## 📞 Resources

- **Full Guide:** LOCAL_DEPLOYMENT_WINDOWS.md
- **GCP Deployment:** DEPLOYMENT_GUIDE.md
- **Killercoda Testing:** KILLERCODA_DEPLOYMENT.md
- **Free Options:** FREE_DEPLOYMENT_OPTIONS.md
- **GitHub Repo:** https://github.com/xyzkpz/java-microservice-gcp-k8s

---

**Deployment Status:** ☐ Not Started  ☐ In Progress  ☐ Completed  ☐ Failed

**Overall Success:** ☐ Yes  ☐ No  ☐ Partial

**Deployment Time:** Start: _______ End: _______ Duration: _______

**Deployed By:** _______________ **Date:** _______________

**Ready for Production:** ☐ Yes  ☐ No  **Reason:** _______________
