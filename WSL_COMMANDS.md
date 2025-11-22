# Next Steps: Using Your Ubuntu 24.04 Installation

## 1. Access Ubuntu
You can launch Ubuntu in several ways:

```powershell
# Method 1: Launch Ubuntu directly
&"C:\Program Files\WSL\wsl.exe" -d Ubuntu-24.04

# Method 2: Launch default WSL distribution
&"C:\Program Files\WSL\wsl.exe"

# Method 3: From Windows Terminal (recommended)
# Just open Windows Terminal and select "Ubuntu-24.04" from the dropdown
```

## 2. Update Ubuntu Packages (First Time Setup)
```bash
# Once inside Ubuntu, run:
sudo apt update
sudo apt upgrade -y
```

## 3. Install Java and Maven in Ubuntu
```bash
# Install Java 17
sudo apt install openjdk-17-jdk -y

# Verify Java installation
java --version

# Install Maven
sudo apt install maven -y

# Verify Maven installation
mvn --version
```

## 4. Install Docker CLI in Ubuntu (to work with Docker Desktop)
```bash
# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI
sudo apt-get update
sudo apt-get install docker-ce-cli -y

# Test Docker (should work with Docker Desktop)
docker --version
```

## 5. Clone Your Project in Ubuntu
```bash
# Navigate to your home directory
cd ~

# Clone your repository
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git

# Navigate to project
cd java-microservice-gcp-k8s

# Build the project
mvn clean package
```

## 6. Access Windows Files from Ubuntu
Your Windows drives are mounted at `/mnt/`:

```bash
# Access C: drive
cd /mnt/c/Users/kkish/

# Access your project from Windows
cd /mnt/c/Users/kkish/.gemini/antigravity/scratch/java-k8s-gcp-deployment
```

## 7. Useful WSL Commands
```powershell
# Stop Ubuntu
&"C:\Program Files\WSL\wsl.exe" --terminate Ubuntu-24.04

# Restart Ubuntu
&"C:\Program Files\WSL\wsl.exe" --shutdown
# Then launch again

# Check WSL status
&"C:\Program Files\WSL\wsl.exe" --list --verbose

# Set Ubuntu as default distribution
&"C:\Program Files\WSL\wsl.exe" --set-default Ubuntu-24.04
```

## 🚀 Recommended Workflow
- Use Windows Terminal - Install from Microsoft Store for the best Ubuntu experience
- Enable Kubernetes in Docker Desktop (Settings → Kubernetes → Enable Kubernetes)
- Develop in WSL/Ubuntu - Use Ubuntu for all development commands
- Access via VS Code - Install "Remote - WSL" extension to edit files directly in Ubuntu
