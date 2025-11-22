# Local Windows Deployment - Automated Script
# This script automates the deployment on your local Windows system

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Java Microservice Local Deployment" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
Write-Host "Step 1: Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker installed: $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host "✗ Docker not found. Please install Docker Desktop!" -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
}
catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop!" -ForegroundColor Red
    exit 1
}

# Check kubectl
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    Write-Host "✓ kubectl installed" -ForegroundColor Green
}
catch {
    Write-Host "✗ kubectl not found. Please enable Kubernetes in Docker Desktop!" -ForegroundColor Red
    exit 1
}

# Check Kubernetes
try {
    kubectl get nodes | Out-Null
    Write-Host "✓ Kubernetes is running" -ForegroundColor Green
}
catch {
    Write-Host "✗ Kubernetes not running. Enable it in Docker Desktop Settings!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Build Docker image
Write-Host "Step 2: Building Docker image..." -ForegroundColor Yellow
Write-Host "(This may take 3-5 minutes on first run)" -ForegroundColor Gray

docker build -t java-microservice:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Verify image
Write-Host "Verifying Docker image..." -ForegroundColor Gray
docker images | Select-String "java-microservice"
Write-Host ""

# Step 3: Create ConfigMap
Write-Host "Step 3: Creating ConfigMap..." -ForegroundColor Yellow

kubectl apply -f k8s/configmap.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ ConfigMap creation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ ConfigMap created" -ForegroundColor Green
Write-Host ""

# Step 4: Create Deployment
Write-Host "Step 4: Creating Deployment..." -ForegroundColor Yellow

# Create local deployment file
$deploymentYaml = @"
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
          value: '{\"app\":{\"name\":\"\$\$(APP_NAME)\",\"version\":\"\$\$(APP_VERSION)\",\"environment\":\"\$\$(APP_ENVIRONMENT)\",\"message\":\"\$\$(APP_MESSAGE)\"}}'
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
"@

$deploymentYaml | Out-File -FilePath k8s/deployment-local.yaml -Encoding utf8
kubectl apply -f k8s/deployment-local.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Deployment creation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Deployment created" -ForegroundColor Green
Write-Host ""

# Step 5: Create Service
Write-Host "Step 5: Creating Service..." -ForegroundColor Yellow

$serviceYaml = @"
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
"@

$serviceYaml | Out-File -FilePath k8s/service-local.yaml -Encoding utf8
kubectl apply -f k8s/service-local.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Service creation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Service created" -ForegroundColor Green
Write-Host ""

# Step 6: Wait for pods
Write-Host "Step 6: Waiting for pods to be ready..." -ForegroundColor Yellow
Write-Host "(This may take 60-90 seconds)" -ForegroundColor Gray

$timeout = 180
$elapsed = 0
$ready = $false

while ($elapsed -lt $timeout) {
    $pods = kubectl get pods -l app=java-microservice -o json | ConvertFrom-Json
    $runningCount = 0
    
    foreach ($pod in $pods.items) {
        if ($pod.status.phase -eq "Running") {
            foreach ($condition in $pod.status.conditions) {
                if ($condition.type -eq "Ready" -and $condition.status -eq "True") {
                    $runningCount++
                }
            }
        }
    }
    
    if ($runningCount -ge 2) {
        $ready = $true
        break
    }
    
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 5
    $elapsed += 5
}

Write-Host ""

if ($ready) {
    Write-Host "✓ Pods are ready!" -ForegroundColor Green
}
else {
    Write-Host "⚠ Pods not ready yet. Check status with: kubectl get pods" -ForegroundColor Yellow
}

Write-Host ""

# Step 7: Display status
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Deployment Status" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pods:" -ForegroundColor Yellow
kubectl get pods -l app=java-microservice
Write-Host ""

Write-Host "Service:" -ForegroundColor Yellow
kubectl get service java-microservice-service
Write-Host ""

Write-Host "ConfigMap:" -ForegroundColor Yellow
kubectl get configmap app-config
Write-Host ""

# Step 8: Test application
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Testing Application" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 5

Write-Host "Testing endpoints..." -ForegroundColor Yellow

try {
    Write-Host ""
    Write-Host "Home endpoint (/):" -ForegroundColor Gray
    $response = Invoke-RestMethod -Uri http://localhost:30080/ -ErrorAction Stop
    $response | ConvertTo-Json
    Write-Host "✓ Home endpoint working!" -ForegroundColor Green
}
catch {
    Write-Host "⚠ Home endpoint not responding yet. Wait 30 seconds and try manually." -ForegroundColor Yellow
}

Write-Host ""

# Final instructions
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Access your application:" -ForegroundColor Green
Write-Host "  http://localhost:30080/" -ForegroundColor White
Write-Host ""

Write-Host "Test endpoints:" -ForegroundColor Green
Write-Host "  curl http://localhost:30080/" -ForegroundColor White
Write-Host "  curl http://localhost:30080/health" -ForegroundColor White
Write-Host "  curl http://localhost:30080/config" -ForegroundColor White
Write-Host ""

Write-Host "View logs:" -ForegroundColor Green
Write-Host "  kubectl logs -l app=java-microservice" -ForegroundColor White
Write-Host ""

Write-Host "Stop application:" -ForegroundColor Green
Write-Host "  kubectl delete -f k8s/service-local.yaml" -ForegroundColor White
Write-Host "  kubectl delete -f k8s/deployment-local.yaml" -ForegroundColor White
Write-Host "  kubectl delete -f k8s/configmap.yaml" -ForegroundColor White
Write-Host ""

Write-Host "Happy testing! 🚀" -ForegroundColor Cyan
