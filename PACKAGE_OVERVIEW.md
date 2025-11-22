# 📦 Java Microservice GCP Deployment Package

**Created:** November 22, 2025  
**Purpose:** Complete deployment package for Java microservice on Google Kubernetes Engine (GKE)

---

## 📁 Package Contents

This package contains everything you need to deploy a Java microservice to GCP Kubernetes:

### **Application Files**
```
├── src/main/java/com/example/
│   ├── Application.java                    # Main Spring Boot application
│   └── controller/
│       └── HealthController.java           # REST API endpoints
├── src/main/resources/
│   └── application.properties              # Application configuration
├── pom.xml                                 # Maven dependencies
└── Dockerfile                              # Multi-stage Docker build
```

### **Kubernetes Manifests** (`k8s/` directory)
```
├── configmap.yaml                          # Application configuration (ConfigMap)
├── deployment.yaml                         # Kubernetes Deployment (3 replicas)
└── service.yaml                            # LoadBalancer Service (port 80)
```

### **Documentation**
```
├── README.md                               # Project overview
├── QUICKSTART.md                           # 5-minute quick start guide ⭐
├── DEPLOYMENT_GUIDE.md                     # Comprehensive deployment guide
└── DEPLOYMENT_CHECKLIST.md                 # Step-by-step checklist
```

### **Deployment Scripts**
```
├── deploy-commands.sh                      # All commands (Linux/Mac)
└── deploy-commands.ps1                     # All commands (Windows PowerShell)
```

---

## 🚀 Where to Start?

### **Choose Your Path:**

#### 🏃 **Fast Track (15 minutes)**
→ Start with **[QUICKSTART.md](QUICKSTART.md)**
- 5 simple steps
- Minimal explanation
- Get running fast

#### 📚 **Detailed Path (30 minutes)**
→ Start with **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**
- Complete explanations
- Troubleshooting tips
- Best practices

#### ✅ **Checklist Approach**
→ Use **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)**
- Print and check off items
- Track progress
- Ensure nothing is missed

---

## 🎯 What This Package Deploys

### **Application Features:**
- ✅ Spring Boot 3.2.0 + Java 17
- ✅ RESTful API with multiple endpoints
- ✅ ConfigMap integration for external configuration
- ✅ Health check endpoints for Kubernetes
- ✅ Production-ready logging and monitoring

### **Kubernetes Setup:**
- ✅ **3 Pod replicas** for high availability
- ✅ **LoadBalancer** for external access on port 80
- ✅ **ConfigMap** for environment-specific configuration
- ✅ **Health probes** (liveness & readiness)
- ✅ **Resource limits** (CPU & Memory)
- ✅ **Auto-scaling ready**

### **API Endpoints:**
| Endpoint | Description |
|----------|-------------|
| `GET /` | Main page with app info |
| `GET /health` | Simple health check |
| `GET /config` | View ConfigMap values |
| `GET /actuator/health` | Detailed health status |

---

## ⚙️ Prerequisites

Before you start, ensure you have:

1. **Google Cloud Platform**
   - [ ] GCP account created
   - [ ] Billing enabled
   - [ ] Project created

2. **Local Tools**
   - [ ] `gcloud` CLI installed and authenticated
   - [ ] `kubectl` installed
   - [ ] `docker` installed and running

3. **Optional (for local testing)**
   - [ ] Java 17+
   - [ ] Maven 3.6+

---

## 📝 Quick Deployment Summary

### **1. Configure GCP**
```bash
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID
```

### **2. Create Cluster**
```bash
gcloud container clusters create java-microservice-cluster \
  --zone=us-central1-a --num-nodes=3
```

### **3. Build & Push**
```bash
docker build -t gcr.io/$PROJECT_ID/java-microservice:latest .
docker push gcr.io/$PROJECT_ID/java-microservice:latest
```

### **4. Deploy**
```bash
kubectl apply -f k8s/
```

### **5. Access**
```bash
kubectl get service java-microservice-service
# Open http://EXTERNAL_IP/ in browser
```

---

## 🏗️ Architecture Overview

```
                    Internet
                       |
                       ↓
              ┌──────────────────┐
              │  LoadBalancer    │  (Port 80)
              │  External IP     │
              └────────┬─────────┘
                       │
                       ↓
              ┌──────────────────┐
              │  K8s Service     │  (ClusterIP)
              └────────┬─────────┘
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
   ┌────────┐    ┌────────┐    ┌────────┐
   │ Pod 1  │    │ Pod 2  │    │ Pod 3  │
   │  :8080 │    │  :8080 │    │  :8080 │
   └────────┘    └────────┘    └────────┘
        ↑              ↑              ↑
        └──────────────┴──────────────┘
                       │
                  ┌────────────┐
                  │ ConfigMap  │
                  │ app-config │
                  └────────────┘
```

---

## 🔧 Key Configuration Points

### **Before Deployment - Must Update:**

1. **In deployment scripts:**
   ```bash
   export PROJECT_ID="your-actual-project-id"  # ← UPDATE THIS
   ```

2. **In `k8s/deployment.yaml`:**
   ```yaml
   image: gcr.io/YOUR_PROJECT_ID/java-microservice:latest  # ← UPDATE THIS
   ```

### **Optional Customizations:**

1. **ConfigMap values** (`k8s/configmap.yaml`):
   - Application name
   - Version
   - Environment
   - Custom message

2. **Resource limits** (`k8s/deployment.yaml`):
   - CPU requests/limits
   - Memory requests/limits
   - Number of replicas

3. **Cluster configuration**:
   - Region/Zone
   - Machine type
   - Number of nodes

---

## 💰 Cost Information

**Estimated Monthly Cost:** ~$100-150

**Breakdown:**
- GKE Cluster Management: ~$73/month (standard)
- 3 × e2-medium instances: ~$75/month
- LoadBalancer: ~$18/month
- Container Registry storage: ~$1-5/month

**💡 Cost Saving Tips:**
- Delete cluster when not in use
- Use smaller instance types for dev/test
- Use preemptible nodes (60-91% cheaper)
- Enable cluster autoscaler

---

## 🛠️ Common Operations

### **View Status**
```bash
kubectl get all
kubectl get pods -l app=java-microservice
```

### **View Logs**
```bash
kubectl logs -l app=java-microservice
kubectl logs -f <pod-name>  # Follow logs
```

### **Scale Application**
```bash
kubectl scale deployment java-microservice --replicas=5
```

### **Update Configuration**
```bash
kubectl edit configmap app-config
kubectl rollout restart deployment java-microservice
```

### **Update Application**
```bash
docker build -t gcr.io/$PROJECT_ID/java-microservice:v2 .
docker push gcr.io/$PROJECT_ID/java-microservice:v2
kubectl set image deployment/java-microservice \
  java-microservice=gcr.io/$PROJECT_ID/java-microservice:v2
```

---

## 🧹 Cleanup

**To delete everything and stop charges:**

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete cluster
gcloud container clusters delete java-microservice-cluster \
  --zone=us-central1-a

# (Optional) Delete container images
gcloud container images delete \
  gcr.io/$PROJECT_ID/java-microservice:latest
```

---

## 📞 Support & Resources

### **Documentation in This Package:**
1. [QUICKSTART.md](QUICKSTART.md) - Fast 5-step guide
2. [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Detailed guide with troubleshooting
3. [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Step-by-step checklist
4. [README.md](README.md) - Project overview

### **External Resources:**
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Documentation](https://docs.docker.com/)

### **Command References:**
- [deploy-commands.sh](deploy-commands.sh) - All commands (Bash)
- [deploy-commands.ps1](deploy-commands.ps1) - All commands (PowerShell)

---

## ✅ Success Criteria

Your deployment is successful when:
- ✅ All 3 pods are in "Running" state
- ✅ LoadBalancer has External IP assigned
- ✅ Can access `http://EXTERNAL_IP/` in browser
- ✅ All endpoints return valid JSON responses
- ✅ ConfigMap values are displayed correctly
- ✅ Health checks are passing

---

## 🎯 Next Steps After Deployment

1. **Security**
   - Set up SSL/TLS with Ingress
   - Configure firewalls and network policies
   - Enable Workload Identity

2. **Monitoring**
   - Set up Cloud Monitoring
   - Configure alerting
   - View logs in Cloud Logging

3. **CI/CD**
   - Set up Cloud Build pipeline
   - Automate deployments
   - Add automated testing

4. **Scaling**
   - Configure Horizontal Pod Autoscaler
   - Set up cluster autoscaler
   - Optimize resource requests

5. **Database**
   - Add Cloud SQL or other database
   - Configure connection secrets
   - Set up database migrations

---

**🎉 You're ready to deploy! Choose your starting point and begin.**

**Recommended:** Start with [QUICKSTART.md](QUICKSTART.md) for fastest results!

---

*Last Updated: November 22, 2025*  
*Package Version: 1.0.0*
