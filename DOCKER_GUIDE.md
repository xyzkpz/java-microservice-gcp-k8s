# 🐳 End-to-End Guide: Running Java Microservice in Docker on Windows

This guide provides step-by-step instructions to clone, build, and run the application on your local Windows machine using Docker.

## ✅ Prerequisites

Before you begin, ensure you have the following installed:
1.  **Git**: [Download Git for Windows](https://git-scm.com/download/win)
2.  **Docker Desktop**: [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
    *   *Make sure Docker Desktop is running before proceeding.*

---

## 🚀 Step-by-Step Instructions

### Step 1: Clone the Repository
Open **PowerShell** or **Command Prompt** and run the following commands to download the project code.

```powershell
# 1. Create a directory for your projects (optional)
mkdir C:\Projects
cd C:\Projects

# 2. Clone the repository
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git
```

### Step 2: Navigate to the Project Directory
Move into the folder you just downloaded.

```powershell
cd java-microservice-gcp-k8s
```

### Step 3: Build the Docker Image
This step packages the Java application into a Docker image. You do **not** need Java or Maven installed on your machine; Docker handles everything.

```powershell
# Build the image and tag it as 'java-microservice'
docker build -t java-microservice:latest .
```
*Tip: The first build may take a few minutes to download dependencies. Please be patient.*

### Step 4: Run the Application Container
Start the application in a container. We map port `8080` inside the container to port `8080` on your Windows machine.

```powershell
# Run in the background (detached mode)
docker run -d -p 8080:8080 --name java-app java-microservice:latest
```

### Step 5: Verify the Application is Running
Check if the container is up and running.

```powershell
# List running containers
docker ps
```
*You should see `java-app` in the list with status `Up`.*

### Step 6: Test the Service
You can access the application using your web browser or terminal.

**Option A: Web Browser**
Click these links to open in your browser:
*   **Home Page:** [http://localhost:8080](http://localhost:8080)
*   **Health Check:** [http://localhost:8080/health](http://localhost:8080/health)
*   **Configuration:** [http://localhost:8080/config](http://localhost:8080/config)

**Option B: PowerShell / Terminal**
```powershell
curl http://localhost:8080/health
```

---

## 🛑 Managing the Application

### Stop the Service
When you are done, you can stop the container.
```powershell
docker stop java-app
```

### Remove the Container
If you want to remove the stopped container (to free up space or run a fresh instance):
```powershell
docker rm java-app
```

### View Application Logs
If something isn't working, check the logs:
```powershell
docker logs -f java-app
```
*(Press `Ctrl+C` to exit the logs)*

---

## ❓ Troubleshooting

**Error: "Bind for 0.0.0.0:8080 failed: port is already allocated"**
*   **Cause:** Another application is using port 8080.
*   **Fix:** Run the container on a different port (e.g., 9090):
    ```powershell
    docker run -d -p 9090:8080 --name java-app java-microservice:latest
    ```
    *Access at `http://localhost:9090`*

**Error: "docker: command not found"**
*   **Cause:** Docker Desktop is not installed or not added to your PATH.
*   **Fix:** Install Docker Desktop and restart your terminal.

**Error: "Cannot connect to the Docker daemon"**
*   **Cause:** Docker Desktop is installed but not running.
*   **Fix:** Open "Docker Desktop" from the Start menu and wait for the engine to start.
