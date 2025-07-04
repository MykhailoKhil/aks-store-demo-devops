# Local Kubernetes Deployment Guide for AKS Store Demo

This guide provides step-by-step instructions for deploying the AKS Store Demo application on a local Kubernetes cluster.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) - Container runtime
- A local Kubernetes cluster (choose one):
  - [Docker Desktop with Kubernetes](https://docs.docker.com/desktop/kubernetes/) (easiest option)
  - [Minikube](https://minikube.sigs.k8s.io/docs/start/)
  - [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes command-line tool
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) - Required for the Ingress resource

## Step 1: Start Your Local Kubernetes Cluster

### Option A: Docker Desktop
1. Open Docker Desktop
2. Go to Settings > Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for Kubernetes to start (green indicator in the bottom-left corner)

### Option B: Minikube
```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=4096m
```

### Option C: Kind
```bash
# Create a Kind cluster
kind create cluster --name aks-store-demo
```

## Step 2: Install NGINX Ingress Controller

The application uses an Ingress resource, so you need to install an Ingress controller:

### For Docker Desktop or Kind:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

### For Minikube:
```bash
minikube addons enable ingress
```

Wait for the Ingress controller to be ready:
```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

## Step 3: Deploy the AKS Store Demo Application

Apply the Kubernetes manifests from the `kubernetes` directory:

```bash
# Apply the main application manifest
kubectl apply -f kubernetes/aks-store.yaml

# Apply the Ingress resource
kubectl apply -f kubernetes/store-ingress.yaml
```

## Step 4: Verify the Deployment

Check if all pods are running:

```bash
kubectl get pods
```

You should see pods for:
- rabbitmq-0
- order-service-*
- product-service-*
- store-front-*

Ensure all pods are in the "Running" state and ready (e.g., 1/1):

```bash
kubectl get pods -o wide
```

Check the services:

```bash
kubectl get services
```

Verify the Ingress resource:

```bash
kubectl get ingress
```

## Step 5: Access the Application

### For Docker Desktop:
The application should be accessible at http://localhost

### For Minikube:
```bash
# Get the IP address
minikube ip
```
Then access the application at http://<minikube-ip>

### For Kind:
Port-forward the Ingress controller to access the application:
```bash
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
```
Then access the application at http://localhost:8080

## Step 6: Explore the Application Components

The AKS Store Demo consists of:

1. **Store Frontend** - Web UI for the store
2. **Product Service** - API for product catalog
3. **Order Service** - API for order processing
4. **RabbitMQ** - Message queue for order processing

You can access the RabbitMQ management interface:
```bash
# Port-forward the RabbitMQ management interface
kubectl port-forward service/rabbitmq 15672:15672
```
Then access it at http://localhost:15672 with username: `username` and password: `password`

## Troubleshooting

### Check Pod Logs
If a pod is not starting or is crashing:
```bash
kubectl logs <pod-name>
```

### Check Pod Details
```bash
kubectl describe pod <pod-name>
```

### Network Policy Issues
If services can't communicate, check the Network Policies:
```bash
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>
```

### Ingress Issues
If the Ingress is not working:
```bash
kubectl describe ingress store-ingress
```

### Restart a Deployment
```bash
kubectl rollout restart deployment <deployment-name>
```

## Cleanup

To remove the application from your cluster:

```bash
kubectl delete -f kubernetes/store-ingress.yaml
kubectl delete -f kubernetes/aks-store.yaml
```

To delete your local cluster (if using Minikube or Kind):

```bash
# For Minikube
minikube stop
minikube delete

# For Kind
kind delete cluster --name aks-store-demo
```
