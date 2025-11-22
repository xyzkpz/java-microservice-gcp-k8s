# Java Microservice for GCP Kubernetes

A simple Java Spring Boot microservice designed to be deployed on Google Kubernetes Engine (GKE) with ConfigMap integration and LoadBalancer access.

## Features

- ✅ Spring Boot 3.2.0 with Java 17
- ✅ RESTful API endpoints
- ✅ Health check endpoints for Kubernetes probes
- ✅ ConfigMap integration for external configuration
- ✅ Multi-stage Docker build for optimized image size
- ✅ Kubernetes manifests (Deployment, Service, ConfigMap)
- ✅ LoadBalancer service for external access on port 80
- ✅ Horizontal Pod Autoscaling ready
- ✅ Production-ready health checks and resource limits

## Quick Start

### Local Development

1. **Build the application:**
   ```bash
   mvn clean package
   ```

2. **Run locally:**
   ```bash
   java -jar target/app.jar
   ```

3. **Test the endpoints:**
   ```bash
   curl http://localhost:8080/
   curl http://localhost:8080/health
   curl http://localhost:8080/config
   ```

### Deploy to GCP

See the comprehensive [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed step-by-step instructions.

### 🆓 Free Deployment Options

**Don't have a GCP account or want to test for free?**

Check out [FREE_DEPLOYMENT_OPTIONS.md](FREE_DEPLOYMENT_OPTIONS.md) for a complete guide on:
- ✅ **Free Kubernetes playgrounds** (no signup required!)
- ✅ **Cloud provider free tiers** ($200-$300 credits)
- ✅ **Always-free options** for long-term learning

**Quick Links:**
- **Instant Testing (No Signup):** [Killercoda](https://killercoda.com/playgrounds/scenario/kubernetes)
- **4-Hour Free Sessions:** [Play with Kubernetes](https://labs.play-with-k8s.com/)
- **Best for Production Testing:** [GCP Free Trial](https://cloud.google.com/free) ($300 credit)

**Quick deployment:**

```bash
# 1. Set your GCP project
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# 2. Create GKE cluster
gcloud container clusters create java-microservice-cluster \
  --zone=us-central1-a \
  --num-nodes=3

# 3. Build and push Docker image
docker build -t gcr.io/$PROJECT_ID/java-microservice:latest .
docker push gcr.io/$PROJECT_ID/java-microservice:latest

# 4. Update deployment.yaml with your PROJECT_ID

# 5. Deploy to Kubernetes
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# 6. Get external IP
kubectl get service java-microservice-service
```

## System Requirements

### Local Windows Development Setup

This project was developed and tested on Windows with WSL (Windows Subsystem for Linux).

#### WSL Installation Steps & Commands

**Step 1: Check WSL Version**
```powershell
C:\...\java-k8s-gcp-deployment> &"C:\Program Files\WSL\wsl.exe" --version

# Output:
WSL version: 2.6.2.0
Kernel version: 6.6.87.2-1
WSLg version: 1.0.71
MSRDC version: 1.2.6353
Direct3D version: 1.611.1-81528511
DXCore version: 10.0.26100.1-240331-1435.ge-release
Windows version: 10.0.19045.6466
```

**Step 2: List Available Distributions Online**
```powershell
C:\...\java-k8s-gcp-deployment> &"C:\Program Files\WSL\wsl.exe" --list --online

# Output:
The following is a list of valid distributions that can be installed.
Install using 'wsl.exe --install <Distro>'.

NAME                            FRIENDLY NAME
Ubuntu                          Ubuntu
Ubuntu-24.04                    Ubuntu 24.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
Ubuntu-20.04                    Ubuntu 20.04 LTS
Debian                          Debian GNU/Linux
kali-linux                      Kali Linux Rolling
openSUSE-Leap-15.6              openSUSE Leap 15.6
# ... (and more distributions available)
```

**Step 3: Install Ubuntu 24.04 LTS**
```powershell
C:\...\java-k8s-gcp-deployment> &"C:\Program Files\WSL\wsl.exe" --install Ubuntu-24.04

# Output (download progress):
Downloading: Ubuntu 24.04 LTS
[==========================100.0%==========================]

Distribution successfully installed. It can be launched via 'wsl.exe -d Ubuntu-24.04'
Launching Ubuntu-24.04...
Provisioning the new WSL instance Ubuntu-24.04
This might take a while...
Create a default Unix user account: <your-username>
New password: <enter-password>
Retype new password: <confirm-password>
```

**Step 4: Verify Installation**
```powershell
C:\...\java-k8s-gcp-deployment> &"C:\Program Files\WSL\wsl.exe" --list --verbose

# Output:
  NAME              STATE           VERSION
* docker-desktop    Running         2
  Ubuntu-24.04      Running         2
```

✅ **Successfully Installed:** Ubuntu 24.04 LTS running on WSL 2

#### Prerequisites for Local Development

- **Operating System:** Windows 10 build 19041+ or Windows 11
- **WSL 2:** Installed ([Download WSL](https://github.com/microsoft/WSL/releases))
  - Recommended: WSL 2.6.2+
  - Linux Distribution: Ubuntu 24.04 LTS or later
- **Docker Desktop:** For Windows with Kubernetes enabled
- **Java:** Version 17 or higher
- **Maven:** Version 3.6 or higher (can be installed in WSL)

#### Automated Setup Script

Run the included PowerShell script to check and guide installation:
```powershell
.\setup-system.ps1
```

This script will:
- ✅ Detect your system specifications
- ✅ Check WSL installation and distributions  
- ✅ Check Docker Desktop installation
- ✅ Verify Kubernetes is enabled
- ✅ Provide download links and guidance if anything is missing

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Home endpoint with app info and ConfigMap values |
| `/health` | GET | Health check endpoint |
| `/config` | GET | Display current configuration from ConfigMap |
| `/actuator/health` | GET | Spring Boot actuator health endpoint |

## Configuration

The application uses ConfigMap for external configuration. Edit `k8s/configmap.yaml` to update:

- `app.name` - Application name
- `app.version` - Application version
- `app.environment` - Environment (dev, staging, production)
- `app.message` - Custom welcome message

## Architecture

```
┌─────────────────┐
│  LoadBalancer   │  (Port 80)
│  External IP    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Service      │  (ClusterIP)
│  (Port 80→8080) │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│         Deployment              │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ Pod1 │ │ Pod2 │ │ Pod3 │   │
│  │:8080 │ │:8080 │ │:8080 │   │
│  └──────┘ └──────┘ └──────┘   │
└─────────────────────────────────┘
         ▲
         │
    ┌────────────┐
    │ ConfigMap  │
    └────────────┘
```

## Technology Stack

- **Language:** Java 17
- **Framework:** Spring Boot 3.2.0
- **Build Tool:** Maven 3.9
- **Container:** Docker
- **Orchestration:** Kubernetes
- **Cloud Platform:** Google Cloud Platform (GKE)

## Project Structure

```
.
├── src/
│   └── main/
│       ├── java/com/example/
│       │   ├── Application.java              # Main application class
│       │   └── controller/
│       │       └── HealthController.java     # REST controller
│       └── resources/
│           └── application.properties         # Default config
├── k8s/
│   ├── configmap.yaml                         # Kubernetes ConfigMap
│   ├── deployment.yaml                        # Kubernetes Deployment
│   └── service.yaml                           # Kubernetes Service (LoadBalancer)
├── Dockerfile                                 # Multi-stage Docker build
├── pom.xml                                    # Maven dependencies
├── DEPLOYMENT_GUIDE.md                        # Detailed deployment guide
└── README.md                                  # This file
```

## Resources

### Kubernetes Resources

- **ConfigMap:** `app-config` - Application configuration
- **Deployment:** `java-microservice` - 3 replicas with auto-scaling
- **Service:** `java-microservice-service` - LoadBalancer on port 80

### Container Resources

- **CPU Request:** 250m (0.25 cores)
- **CPU Limit:** 500m (0.5 cores)
- **Memory Request:** 512Mi
- **Memory Limit:** 1Gi

## Monitoring

The application includes:

- **Liveness Probe:** `/actuator/health` (checks if app is running)
- **Readiness Probe:** `/actuator/health` (checks if app is ready to serve traffic)
- **Actuator Endpoints:** Health and info endpoints enabled

## License

MIT License

## Support

For detailed deployment instructions, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
