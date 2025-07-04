# AKS Store Demo Deployment Guide

This guide provides step-by-step instructions for deploying the AKS Store Demo application either on a local Kubernetes cluster or on Azure using Terraform.

## Deployment Options

- [Local Kubernetes Deployment](#local-kubernetes-deployment)
- [Azure Deployment with Terraform](#azure-deployment-with-terraform)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) - Container runtime
- A local Kubernetes cluster (choose one):
  - [Docker Desktop with Kubernetes](https://docs.docker.com/desktop/kubernetes/) (easiest option)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes command-line tool
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) - Required for the Ingress resource

## Step 1: Start Your Local Kubernetes Cluster

### Option A: Docker Desktop
1. Open Docker Desktop
2. Go to Settings > Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for Kubernetes to start (green indicator in the bottom-left corner)

## Step 2: Install NGINX Ingress Controller

The application uses an Ingress resource, so you need to install an Ingress controller:
```bash 
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx    
  helm repo update    
  helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx
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

## Azure Deployment with Terraform

### Prerequisites for Azure Deployment

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (version 2.30.0 or later)
- [Terraform](https://www.terraform.io/downloads.html) (version 1.0.0 or later)
- SSH key pair (for AKS node access)

### Step 1: Authenticate to Azure

```bash
# Login to Azure
az login

# (Optional) If you have multiple subscriptions, select the one you want to use
az account set --subscription "your-subscription-id"
```

### Step 2: Deploy with Terraform

```bash
# Navigate to the terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

When prompted, type `yes` to confirm the deployment. The process typically takes 10-15 minutes.

### Step 3: Configure kubectl

```bash
# Configure kubectl to connect to your AKS cluster
$(terraform output -raw kubectl_config_command)

# Verify the connection
kubectl get nodes
```

### Cleanup Azure Resources

To remove all Azure resources when you're done:

```bash
terraform destroy
```

When prompted, type `yes` to confirm.

For more detailed instructions, advanced configurations, and troubleshooting, see the [detailed Terraform guide](terraform/README.md).
