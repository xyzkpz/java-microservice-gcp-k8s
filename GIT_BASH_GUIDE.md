# 🚀 Git Bash Quick Start Guide

## ✅ You Have Git Bash - Perfect!

Git Bash is great for running these scripts. Here's how to use it:

---

## 🎯 **Quick Start (2 Commands):**

Open **Git Bash** and run:

```bash
# Navigate to project
cd /c/Users/kkish/.gemini/antigravity/scratch/java-k8s-gcp-deployment

# Run setup script
bash setup-system.sh
```

That's it! The script will:
- ✅ Detect your system
- ✅ Show you Docker Desktop download link
- ✅ Optionally download it for you
- ✅ Guide you through installation

---

## 📋 **Step-by-Step:**

### **Step 1: Open Git Bash**
- Press **Windows key**
- Type "**Git Bash**"
- Press **Enter**

### **Step 2: Navigate to Project**
```bash
cd /c/Users/kkish/.gemini/antigravity/scratch/java-k8s-gcp-deployment
```

### **Step 3: Run Setup Script**
```bash
bash setup-system.sh
```

### **Step 4: Follow Instructions**
The script will guide you through:
- Downloading Docker Desktop
- Installing it
- Enabling Kubernetes

---

## 🔧 **All Commands You Need:**

### **System Setup:**
```bash
# Check if Docker is installed
docker --version

# Check if Kubernetes is running
kubectl get nodes

# Run setup script
bash setup-system.sh
```

### **After Docker is Installed:**
```bash
# Build and deploy your app
bash killercoda-deploy.sh

# Or use kubectl commands
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## 💡 **Git Bash vs PowerShell:**

| Task | Git Bash | PowerShell |
|------|----------|------------|
| Setup script | `bash setup-system.sh` | `.\setup-system.ps1` |
| Deploy script | `bash killercoda-deploy.sh` | `.\deploy-local.ps1` |
| Navigate | `cd /c/Users/...` | `cd C:\Users\...` |

**You can use either!** Git Bash is simpler for these scripts.

---

## 🎯 **What to Do Right Now:**

### **In Git Bash:**

```bash
# 1. Go to project directory
cd /c/Users/kkish/.gemini/antigravity/scratch/java-k8s-gcp-deployment

# 2. Run setup
bash setup-system.sh

# 3. Follow the instructions to:
#    - Download Docker Desktop
#    - Install it
#    - Enable Kubernetes

# 4. After installation, deploy your app
docker build -t java-microservice:latest .
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/
```

---

## 🆘 **Common Git Bash Issues:**

### **Issue: "command not found"**
**Solution:** Make sure you're in the right directory:
```bash
pwd  # Should show: /c/Users/kkish/.gemini/antigravity/scratch/java-k8s-gcp-deployment
ls   # Should show files like setup-system.sh
```

### **Issue: "Permission denied"**
**Solution:** Make script executable:
```bash
chmod +x setup-system.sh
bash setup-system.sh
```

### **Issue: Script not running**
**Solution:** Use `bash` explicitly:
```bash
bash setup-system.sh
```

---

## ✅ **After Docker Desktop is Installed:**

Test that everything works:

```bash
# Test Docker
docker --version
docker ps

# Test Kubernetes
kubectl version --client
kubectl get nodes

# If all good, deploy your app
docker build -t java-microservice:latest .
kubectl apply -f k8s/configmap.yaml
```

---

## 📁 **Files You Can Run in Git Bash:**

| File | Purpose | Command |
|------|---------|---------|
| `setup-system.sh` | Setup Docker Desktop | `bash setup-system.sh` |
| `killercoda-deploy.sh` | Deploy to Kubernetes | `bash killercoda-deploy.sh` |
| `deploy-commands.sh` | All deployment commands | Check file for commands |

---

## 🎉 **Quick Reference:**

### **Navigate to Project:**
```bash
cd /c/Users/kkish/.gemini/antigravity/scratch/java-k8s-gcp-deployment
```

### **Run Setup:**
```bash
bash setup-system.sh
```

### **Check Docker:**
```bash
docker --version
docker ps
```

### **Check Kubernetes:**
```bash
kubectl get nodes
```

### **Deploy App:**
```bash
docker build -t java-microservice:latest .
kubectl apply -f k8s/
```

### **Check Running App:**
```bash
kubectl get pods
kubectl get svc
```

### **Access App:**
Open browser: `http://localhost:30080/`

---

## 📞 **Need Help?**

Run the setup script and it will guide you:
```bash
bash setup-system.sh
```

---

**Ready? Open Git Bash and run the commands above!** 🚀
