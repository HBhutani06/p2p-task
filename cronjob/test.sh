#!/bin/sh

# Set AWS Credentials
# it is getting authenticate with eks cluster via the service account annotiontion
# # Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl."
    exit 1
fi

# Check if kubectl can communicate with the API server
if kubectl cluster-info &> /dev/null; then
    echo "Successfully connected to the EKS Kubernetes API server."
else
    echo "Unable to communicate with the EKS Kubernetes API server."
    exit 1
fi

# Function to check if all pods in a deployment are ready
check_deployment_health() {
    namespace=$1
    deployment=$2
    desired=$(kubectl -n $namespace get deployment $deployment -o=jsonpath='{.spec.replicas}')
    ready=$(kubectl -n $namespace get deployment $deployment -o=jsonpath='{.status.readyReplicas}')

    if [ "$desired" != "$ready" ]; then
        echo "Deployment $deployment in Namespace $namespace: Unhealthy - $ready out of $desired pods ready"
    else
        echo "Deployment $deployment in Namespace $namespace: Healthy - All $desired pods ready"
    fi
}

# Get list of namespaces
namespaces=$(kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}')

# Loop through each namespace
for namespace in $namespaces; do
    echo "Checking deployments in Namespace: $namespace"
    # Get list of deployments in the namespace
    deployments=$(kubectl -n $namespace get deployments -o=jsonpath='{.items[*].metadata.name}')
    # Loop through each deployment and check health
    for deployment in $deployments; do
        check_deployment_health $namespace $deployment
    done
done