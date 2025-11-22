# 🆓 Free Kubernetes Deployment Options for Testing

This guide lists **FREE** platforms where you can deploy and test your Java microservice without spending money.

---

## 🏆 Best Options for Your Use Case

### ⭐ **Option 1: Google Cloud Platform (GCP) - RECOMMENDED**

**Why Best for You:**
- You already have the deployment package configured for GKE
- Most generous free tier for Kubernetes
- Full LoadBalancer support

**Free Credits:**
- **$300 free credits** for 90 days (New customers)
- **$74.40/month** ongoing free credit (covers 1 GKE cluster management fee)
- No cluster management fee for one Autopilot or Zonal cluster

**How to Get Started:**
1. Sign up at: https://cloud.google.com/free
2. Get $300 credit (valid 90 days)
3. Follow the QUICKSTART.md guide in this repo
4. After trial, use 1 free zonal cluster indefinitely

**Note:** You need a credit card, but won't be charged during trial period.

**Duration:** 90 days with $300 credit, then free tier continues for 1 cluster

---

### ⭐ **Option 2: Killercoda (Katacoda Alternative) - INSTANT ACCESS**

**Perfect for quick testing without signup hassle!**

**Free Tier:**
- ✅ NO credit card required
- ✅ Pre-configured Kubernetes clusters
- ✅ Instant access in browser
- ✅ Single and multi-node clusters available

**Limitations:**
- Sessions expire after inactivity
- Temporary environments (not persistent)
- Great for testing, not for long-term deployment

**How to Use:**
1. Visit: https://killercoda.com/playgrounds/scenario/kubernetes
2. Click "Start Scenario"
3. Get instant access to Kubernetes cluster
4. Deploy using kubectl commands from our guide

**Perfect For:** Quick testing without commitment

---

### ⭐ **Option 3: Play with Kubernetes (PWK) - 4-HOUR FREE SESSIONS**

**100% Free, No Credit Card, No Signup Required!**

**Free Tier:**
- ✅ Completely FREE
- ✅ No credit card needed
- ✅ 5-node Kubernetes cluster
- ✅ 4-hour sessions
- ✅ Can restart anytime

**How to Use:**
1. Visit: https://labs.play-with-k8s.com/
2. Click "Start"
3. Add 5 instances (nodes)
4. Initialize Kubernetes cluster
5. Deploy your application

**Limitations:**
- Session expires after 4 hours
- Need to redeploy each time
- No persistence between sessions

**Perfect For:** Hands-on testing and learning

---

## 🌟 Other Excellent Free Options

### **4. IBM Cloud - FREE Kubernetes Cluster**

**Free Tier:**
- 1 free Kubernetes cluster
- Single worker node
- 30 days free
- $200 credit for new users

**Signup:** https://cloud.ibm.com/kubernetes/catalog/create
**Requirements:** Credit card required

---

### **5. Microsoft Azure - AKS**

**Free Credits:**
- $200 credit for 30 days
- Free for AI/ML workloads (always free)

**Signup:** https://azure.microsoft.com/free/
**Requirements:** Credit card required

---

### **6. Alibaba Cloud**

**Free Credits:**
- $300 credit valid for 12 months
- Kubernetes in "always free" tier

**Signup:** https://www.alibabacloud.com/free
**Requirements:** Credit card required

---

### **7. Oracle Cloud - Always Free Tier**

**Free Tier:**
- Always-free Kubernetes cluster possible
- No expiration for free tier

**Signup:** https://www.oracle.com/cloud/free/
**Requirements:** Credit card required

---

### **8. Iximiuz Labs**

**Free Tier:**
- Free playgrounds and challenges
- Multi-node Kubernetes clusters
- Pre-configured environments

**Signup:** https://labs.iximiuz.com/playgrounds
**Requirements:** GitHub account

---

### **9. LabEx Kubernetes Playground**

**Free Tier:**
- Full Kubernetes sandbox
- Visual Studio Code WebIDE
- Terminal access
- Structured learning courses

**Signup:** https://labex.io/playgrounds/kubernetes
**Requirements:** Email signup

---

## 📊 Comparison Table

| Platform | Cost | Credit Card | Duration | LoadBalancer | Best For |
|----------|------|-------------|----------|--------------|----------|
| **GCP** | $300 credit | Yes | 90 days + ongoing | ✅ Yes | **Production-like testing** |
| **Killercoda** | Free | No | Per session | ❌ No | **Quick testing** |
| **Play with K8s** | Free | No | 4 hours | Limited | **Learning** |
| **IBM Cloud** | $200 credit | Yes | 30 days | ✅ Yes | **Testing** |
| **Azure** | $200 credit | Yes | 30 days | ✅ Yes | **Testing** |
| **Alibaba** | $300 credit | Yes | 12 months | ✅ Yes | **Long-term testing** |
| **Oracle** | Always Free | Yes | No limit | ✅ Yes | **Permanent free** |
| **Iximiuz** | Free | No | Limited | ❌ No | **Learning** |
| **LabEx** | Free | No | Limited | ❌ No | **Learning** |

---

## 🎯 My Recommendation Based on Your Needs

### **For Immediate Testing (Right Now):**
**Use Killercoda or Play with Kubernetes**
- No signup hassle
- Instant access
- Perfect for testing your deployment

### **For Serious Testing with LoadBalancer:**
**Use Google Cloud Platform (GCP)**
- Your deployment is already configured for GCP
- $300 credit is generous
- Full LoadBalancer support
- Best matches your deployment guide

### **For Long-Term Free Access:**
**Use Oracle Cloud Always Free Tier**
- No expiration
- Truly free forever
- Good for ongoing learning

---

## 🚀 Quick Start Guide for Each Platform

### **A. For Killercoda (Easiest - No Signup)**

```bash
# 1. Go to: https://killercoda.com/playgrounds/scenario/kubernetes

# 2. Once in the terminal, verify cluster
kubectl get nodes

# 3. Clone your repo
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git
cd java-microservice-gcp-k8s

# 4. Note: LoadBalancer may not work, use NodePort instead
# Edit k8s/service.yaml and change type to NodePort

# 5. Deploy
kubectl apply -f k8s/
```

---

### **B. For Play with Kubernetes**

```bash
# 1. Go to: https://labs.play-with-k8s.com/

# 2. Click "+ ADD NEW INSTANCE" 5 times (create 5 nodes)

# 3. On node1, initialize cluster
kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16

# 4. Set up kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 5. Install network plugin
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

# 6. Get join command
kubeadm token create --print-join-command

# 7. On other nodes (node2-5), paste the join command

# 8. Deploy your app
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git
cd java-microservice-gcp-k8s
kubectl apply -f k8s/
```

---

### **C. For GCP (Most Complete)**

```powershell
# 1. Sign up at: https://cloud.google.com/free

# 2. Follow the complete guide in QUICKSTART.md

# 3. You'll get $300 credit for 90 days
```

---

## 💡 Tips for Free Tier Usage

1. **Start with No-Signup Options First:**
   - Try Killercoda or Play with K8s first
   - Get familiar with deployment process
   - No commitment needed

2. **Then Move to GCP:**
   - Once comfortable, use GCP free trial
   - Most production-like experience
   - Full LoadBalancer support

3. **LoadBalancer Limitations:**
   - Free playgrounds often don't support LoadBalancer
   - Use NodePort instead for testing
   - Or use port-forwarding: `kubectl port-forward svc/java-microservice-service 8080:80`

4. **Save Money Tips:**
   - Delete clusters when not using
   - Use smallest instance types
   - Set billing alerts
   - Monitor credit usage

---

## 📞 Need Help?

- **For GCP deployment:** Follow QUICKSTART.md in this repo
- **For playground issues:** Check platform documentation
- **For Kubernetes commands:** Refer to deploy-commands.ps1

---

## ✅ Recommended Path

**Day 1:** Test on **Killercoda** (5 minutes)
- Instant access
- No signup
- Quick validation

**Day 2:** Test on **Play with K8s** (30 minutes)
- Multi-node cluster
- Full Kubernetes experience
- Free practice

**Day 3+:** Deploy on **GCP Free Trial** (Full deployment)
- Use $300 credit
- Production-like setup
- Complete LoadBalancer testing

---

**Ready to start? Pick an option above and begin testing! 🚀**

**Easiest Start:** https://killercoda.com/playgrounds/scenario/kubernetes
