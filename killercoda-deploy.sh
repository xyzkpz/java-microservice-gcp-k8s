#!/bin/bash

# ========================================
# Killercoda Deployment Script
# Copy and paste this entire script into Killercoda terminal
# ========================================

echo "🚀 Starting deployment of Java Microservice on Killercoda..."
echo ""

# Step 1: Verify cluster
echo "Step 1: Verifying Kubernetes cluster..."
kubectl get nodes
echo ""

# Step 2: Clone repository
echo "Step 2: Cloning repository..."
git clone https://github.com/xyzkpz/java-microservice-gcp-k8s.git
cd java-microservice-gcp-k8s
echo "✅ Repository cloned"
echo ""

# Step 3: Build Docker image
echo "Step 3: Building Docker image (this may take 2-3 minutes)..."
docker build -t java-microservice:latest .
echo "✅ Docker image built"
echo ""

# Step 4: Apply ConfigMap
echo "Step 4: Creating ConfigMap..."
kubectl apply -f k8s/configmap.yaml
echo "✅ ConfigMap created"
echo ""

# Step 5: Create modified deployment for Killercoda
echo "Step 5: Creating Deployment..."
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

kubectl apply -f k8s/deployment-killercoda.yaml
echo "✅ Deployment created"
echo ""

# Step 6: Create NodePort service
echo "Step 6: Creating NodePort Service..."
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

kubectl apply -f k8s/service-killercoda.yaml
echo "✅ Service created"
echo ""

# Step 7: Wait for pods to be ready
echo "Step 7: Waiting for pods to be ready (this may take 60-90 seconds)..."
kubectl wait --for=condition=ready pod -l app=java-microservice --timeout=180s
echo ""

# Step 8: Display status
echo "========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "========================================="
echo ""

echo "📊 Deployment Status:"
kubectl get pods -l app=java-microservice
echo ""

echo "🌐 Service Status:"
kubectl get svc java-microservice-service
echo ""

echo "========================================="
echo "🎯 How to Access Your Application:"
echo "========================================="
echo ""
echo "Option 1 - Port Forward (RECOMMENDED):"
echo "  kubectl port-forward svc/java-microservice-service 8080:80"
echo "  Then click on port 8080 in Killercoda UI"
echo ""
echo "Option 2 - Direct NodePort Access:"
echo "  curl http://localhost:30080/"
echo ""
echo "Option 3 - Using Cluster IP:"
CLUSTER_IP=$(kubectl get svc java-microservice-service -o jsonpath='{.spec.clusterIP}')
echo "  curl http://$CLUSTER_IP/"
echo ""

echo "========================================="
echo "📝 Test Commands:"
echo "========================================="
echo ""
echo "# Test home endpoint:"
echo "curl http://localhost:30080/"
echo ""
echo "# Test health endpoint:"
echo "curl http://localhost:30080/health"
echo ""
echo "# Test config endpoint:"
echo "curl http://localhost:30080/config"
echo ""
echo "# View logs:"
POD_NAME=$(kubectl get pods -l app=java-microservice -o jsonpath='{.items[0].metadata.name}')
echo "kubectl logs $POD_NAME"
echo ""

echo "========================================="
echo "🎉 Deployment Successful!"
echo "========================================="
