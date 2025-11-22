# 🐳 Running the Application in Docker

This guide explains how to build and run the Java Microservice locally using Docker. This ensures the application runs in the exact same environment as it will in production.

## ✅ Prerequisites

- **Docker Desktop** installed and running.
- **PowerShell** or **WSL (Ubuntu)** terminal.

---

## 🚀 Step 1: Build the Docker Image

You don't need to install Maven or Java locally! The Dockerfile handles the build process for you.

Run this command in the root directory of the project (where `Dockerfile` is located):

```bash
# Build the image and tag it as 'java-microservice'
docker build -t java-microservice:latest .
```

> **Note:** The first build might take a few minutes as it downloads Maven dependencies. Subsequent builds will be much faster.

---

## ▶️ Step 2: Run the Container

Once the image is built, run it as a container. We map port `8080` of the container to port `8080` on your machine.

```bash
# Run in detached mode (background)
docker run -d -p 8080:8080 --name java-app java-microservice:latest

# OR run in interactive mode (to see logs immediately)
docker run -p 8080:8080 --name java-app java-microservice:latest
```

---

## 🧪 Step 3: Test the Application

Open your browser or use `curl` to verify the app is running.

**Browser URLs:**
- Home: [http://localhost:8080](http://localhost:8080)
- Health Check: [http://localhost:8080/health](http://localhost:8080/health)
- Config: [http://localhost:8080/config](http://localhost:8080/config)

**Command Line (PowerShell or WSL):**
```bash
curl http://localhost:8080/health
```

---

## 🛠 Common Docker Commands

Here are useful commands to manage your container:

| Action | Command |
|--------|---------|
| **View Logs** | `docker logs -f java-app` |
| **Stop App** | `docker stop java-app` |
| **Start App** | `docker start java-app` |
| **Remove Container** | `docker rm -f java-app` |
| **Remove Image** | `docker rmi java-microservice:latest` |
| **List Containers** | `docker ps` |

---

## 🔍 Troubleshooting

**1. Port 8080 is already in use**
If you see an error saying the port is allocated, try mapping to a different local port (e.g., 9090):
```bash
docker run -d -p 9090:8080 --name java-app java-microservice:latest
```
Then access at `http://localhost:9090`.

**2. "Connection Refused"**
- Ensure the container is running: `docker ps`
- Check logs for startup errors: `docker logs java-app`

**3. Rebuilding after code changes**
If you modify the Java code, you must rebuild the image and restart the container:
```bash
docker stop java-app
docker rm java-app
docker build -t java-microservice:latest .
docker run -d -p 8080:8080 --name java-app java-microservice:latest
```
