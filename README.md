# Infrastructure Setup using Terragrunt

This repository contains infrastructure setup code managed using Terragrunt.

## Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account**: You need an AWS account to deploy the infrastructure components.
2. **S3 Bucket**: Create an S3 bucket named `aws-go-app-terraform-state-backend` to store Terraform state files. Ensure that versioning is enabled on this bucket.
3. **EksReadOnly role**: for crobjob to authenticate with the eks cluster, need to create a role, and associte the role arn with the service account annotations


## Setup Instructions 

1. **S3 Bucket Creation**:
   - Create an S3 bucket named `aws-go-app-terraform-state-backend` to store Terraform state files.
   - Enable versioning on the bucket.

2. **Backend Configuration**:
   - Edit `backend.hcl` file in the `deployment` directory.
   - Replace `bucket`, `key`, `region`, and `dynamodb_table` values with your S3 bucket details.

3. **Provider Configuration**:
   - Edit `environment.hcl` file in the `deployment` directory.
   - Replace `profile` with your configured aws profile.
   - Adjust `region` as per your AWS region preference.

4. **Terragrunt Commands**:
   - To initialize Terragrunt, navigate to the desired directory containing `terragrunt.hcl` files.
   - Run `terragrunt init` to initialize Terragrunt.
   - Run `terragrunt plan` to see the execution plan.
   - Run `terragrunt apply` to apply the changes.

5. **Environment Configuration**:
   - Edit `region.hcl` files in the respective environment directories to configure region-specific settings.

6. **Module Configuration**:
   - Modify Terraform files in the `modules` directory as per your infrastructure requirements.

## Configuration Details of the terragrunt.hcl files

### Includes

The configuration includes the following HCL files:

- `backend.hcl`: Contains settings for Terraform backend configuration.
- `environment.hcl`: Holds environment-specific configurations.
- `region.hcl`: Contains region-specific configurations.

### Locals

Local variables are defined to read configurations from the included files:

- `env_vars`: Reads environment configurations.
- `region_vars`: Reads region-specific configurations.

### Terraform Configuration

The `terraform` block specifies the source for Terraform modules, which in this case is located at `"../../../../../modules/`.

### Inputs

The `inputs` section merges configurations from the included files along with additional configurations specified in this file.


## Usage

To use this configuration, ensure you have Terraform installed and configured with appropriate AWS credentials. Then, update the input variables in `main.tf` as needed and run:

```bash
terraform init
terraform plan
terraform apply   

## Terraform Commands

- `terragrunt init`: Initialize Terragrunt.
- `terragrunt plan`: Preview changes before applying.
- `terragrunt apply`: Apply changes to infrastructure.
- `terragrunt destroy`: Destroy provisioned infrastructure.
```
## Resource Creation

1. **VPC**: 
    - Terraform configuration: `terraform { source = "../../../../../modules/vpc" }`
    - Configuration details: 
        - Defines the VPC settings such as CIDR block, public IP mapping, DNS settings, and availability zones.
    - Input variables:
        - Ensure the `name_prefix`, `cidr_block`, `map_public_ip_on_launch`, `enable_dns_hostnames`, `enable_dns_support`, and `az_names` are properly set in `main.tf`.

2. **EKS Cluster**:
    - Terraform configuration: `terraform { source = "../../../../../modules/eks" }`
    - Configuration details: 
        - Sets up the EKS cluster, including IAM roles, node groups, instance types, and scaling configurations.
    - Input variables:
        - Ensure the `iam_role_name`, `eks_cluster_name`, `ng_role_name`, `node_group_name`, `instance_types`, `desired_capacity`, `max_capacity`, `min_capacity`, `eks_vpc_config`, and `node_group_vpc_config` are properly set in `main.tf`.

3. **EKS Addons**:
    - Terraform configuration: `terraform { source = "../../../../../modules/eks-addons" }`
    - Configuration details:
        - Configures various addons for the EKS cluster, such as AWS Load Balancer Controller, Cluster Autoscaler, Cert Manager, Ingress Nginx, aws-ebs-csi-driver,metrics-server and sealed-secretsetc.
    - Input variables:
        - Ensure proper configurations for each addon are set in `main.tf`.

4. **ArgoCD**:
    - Terraform configuration: `terraform { source = "../../../../../modules/helm-bootstrap-argocd" }`
    - Configuration details:
        - Deploys ArgoCD for managing Kubernetes applications.
    - Input variables:
        - Ensure the `cluster-name`, `name`, `chart_name`, `chart_repository`, `argo-version`, `namespace`, and `timeout` are properly set in `main.tf`.
5. **ECR**:
    - Terraform configuration: `terraform { source = "../../../../../modules/ecr" }` 
    - Configuration details: 
        - Sets up the ECR to the images       

# Dockerizing the Go Application and pushing to the ECR

Once the infrastructure is created, you can Dockerize your Go application using the provided Dockerfile.

Use the following steps to authenticate and push an image to your repository. For additional registry authentication methods, including the Amazon ECR credential helper, see Registry Authentication .

- Retrieve an authentication token and authenticate your Docker client to your registry.
Use the AWS CLI:
```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```
- Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built
```
docker build -t ue1-dev-ecr -f "path/Dockrfile"
```
- After the build completes, tag your image so you can push the image to this repository:
```
docker tag ue1-dev-ecr:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/ue1-dev-ecr:latest
```
- Run the following command to push this image to your newly created AWS repository:
```
docker push 121837913390.dkr.ecr.us-east-1.amazonaws.com/ue1-dev-ecr:latest
```

In the same way you can build the docker image for the cronjob and push to the ECR repo.

## Dockerfile Features

This Dockerfile showcases several best practices for creating Docker images, including lightweight base images, multi-stage builds, non-root user setup, and health checks.

## Features

- **Lightweight Base Image**: Utilizes Alpine Linux, known for its small size, reducing the overall image footprint.
- **Multi-stage Build**: Utilizes a two-stage build process. The first stage builds the Go binary, and the second stage creates a final lightweight container with only necessary artifacts.
- **Non-root User**: Creates a non-root user (`myuser`) inside the container to enhance security.
- **Health Check**: Implements a health check mechanism to ensure the application is running correctly. It checks every 30 seconds with a timeout of 5 seconds, verifying the availability of the application endpoint.

## Dockerfile Explanation

- **Stage 1 (Build)**: Utilizes the `golang:1.20-alpine` base image to compile the Go application. It sets up the working directory, copies the source code,

## GitHub Actions Workflow
The repository includes a GitHub Actions workflow named `build.yaml` in the .github/workflows folder, which automates the build process of the Dockerized go application and push to ECR

### Pre-requisites

Before using the GitHub Actions workflow, make sure to set up the following GitHub secrets in your repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_ECR_REPO`

# Helm Chart for Go App Deployment

Once the docker image gets created, you can create the helmchart for your Go application.
This Helm chart provides a template for deploying a Go application on Kubernetes using Helm. It includes configuration options for various Kubernetes resources, such as deployments, services, ingress, secrets, and more.

## Helm Chart Structure

- **Chart.yaml**: Metadata file containing information about the Helm chart.
- **values.yaml**: Configuration file containing default values for the Helm chart.
- **templates/**: Directory containing Kubernetes YAML templates for deploying resources.
- **charts/**: Directory where Helm stores dependencies, if any.

## Templates Explanation

### deployment.yaml
This file contains the template for Kubernetes Deployment resource. It defines how the Go application will be deployed, including container specifications, environment variables, resource limits, and more.

### cronjob.yaml
This file containes the crons which will get executed in every 1 minute, its image contains a scipt which will check the Deployment availabilty status.

### hpa.yaml
The Horizontal Pod Autoscaler (HPA) template defines the autoscaling behavior for the application based on CPU and memory utilization. It specifies minimum and maximum replicas, as well as target CPU and memory utilization percentages.

### ingress.yaml
The Ingress template configures the Kubernetes Ingress resource, which exposes the application to external traffic. It includes options for enabling/disabling, specifying annotations, and defining host and path rules.

### pvc.yaml
This template creates a Persistent Volume Claim (PVC) for storing data persistently. It specifies the access mode and storage size required by the application.

### role.yaml
The Role template defines a Kubernetes Role resource for controlling access to other resources within the cluster. It grants permissions necessary for the application to function properly.

### rolebinding.yaml
The RoleBinding template binds the Role defined in `role.yaml` to a ServiceAccount, enabling the application to access the resources specified in the Role.

### secrets.yaml
This template creates Kubernetes Secret resources for storing sensitive data such as usernames and passwords required by the application.

### service.yaml
The Service template defines a Kubernetes Service resource for exposing the application within the cluster. It specifies the type of service (ClusterIP, NodePort, LoadBalancer), as well as the port on which the service listens.

### serviceaccount.yaml
This template creates a Kubernetes ServiceAccount resource, which provides an identity for processes running in a Pod. It may be associated with Roles and RoleBindings to grant specific permissions.

### tests/
This directory contains YAML files used for testing the Helm chart installation. These files may include configuration to verify that the deployed resources are functioning correctly.

## Values.yaml Explanation

#### image
Specifies the Docker image to be used for the application, including the repository, pull policy, and tag.
```yaml
image:
  repository: python-app
  pullPolicy: IfNotPresent
  tag: "latest"

cronJob:
  image:
    repository: cronjobimage
    tag: latest
    pullPolicy: IfNotPresent  
``` 
- **repository**: Specifies the repository for the Docker image of the Python application and the cronjob
- **pullPolicy**: Specifies the pull policy for the Docker image.
- **tag**: Overrides the image tag.

#### secrets
Defines the username and password for any secrets needed by the application.
```yaml
createSecret: false

secrets:
  username: admin
  password: adminpassword
``` 

#### serviceAccount
Specifies whether a Kubernetes service account should be created for the application also add the annotation with the IAM role to access the AWS resources.
```yaml
serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<role-name>
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""
```
#### service
Configures the Kubernetes service for the application, including the type of service (ClusterIP, NodePort, LoadBalancer) and the port on which the service listens.
```yaml
service:
  type: ClusterIP
  port: 3000
```

#### ingress
Controls the configuration of the Kubernetes Ingress resource, including enabling/disabling, specifying annotations, and defining host and path rules.
```yaml
ingress:
  enabled: false
  className: ""
  annotations: {}
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
```

#### resources
Defines resource requests and limits for CPU and memory usage by the application.
```yaml
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 128Mi  
``` 

#### autoscaling
Configures Horizontal Pod Autoscaler (HPA) for the application, enabling autoscaling based on CPU and memory utilization(scale the pod when CPU/memory gets utilized 80%).
```yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

#### pvc
Specifies the Persistent Volume Claim (PVC) for storing data persistently, including access mode and storage size. also define where the storage will get attach on the deployment
```yaml
pvc:
  accessMode: ReadWriteOnce
  storageSize: 1Gi  

volumes:
  - name: pvc-volume
    pvcName: prod-pvc
    mountPath: /data
    diskSize: 30Gi
```
## EKS Cluster Installation using Terraform and terragrunt
Navigate to the `deployment/environment/development/us-east-1/eks` directory containing the Terragrunt configuration file (`terragrunt.hcl`). Update the configuration according to your environment, including dependencies and input variables.

According to the EKS module main.tf file that contains all the resources for deploying an Amazon EKS cluster using Terraform:
```bash
resource "aws_iam_role" "demo" {
  name = var.iam_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
```
This resource defines an IAM role (demo) that allows Amazon EKS service to assume this role. The IAM role's name is provided through the iam_role_name variable.
```bash
resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}
```
This resource attaches the AmazonEKSClusterPolicy policy to the IAM role created earlier. This policy grants permissions necessary for Amazon EKS to manage the cluster.
```bash
resource "aws_eks_cluster" "demo" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.demo.arn

  vpc_config {
    subnet_ids = jsondecode(var.eks_vpc_config)
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}
```
This resource defines the AWS EKS cluster (demo). It specifies the cluster's name and assigns the IAM role created earlier (demo) to the cluster. It also specifies the VPC configuration for the cluster using the subnet IDs provided through the eks_vpc_config variable.
```bash
resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = var.eks_cluster_name
  addon_name        = "vpc-cni"
  addon_version     = "v1.16.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_cluster.demo
  ]
}
```
This resource installs the VPC CNI (Container Network Interface)imilar resources for CoreDNS and kube-proxy add-on to the EKS cluster. It ensures proper networking configuration for pods running on the cluster.
```bash
data "tls_certificate" "eks" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}
```
This data source fetches the TLS certificate data for the EKS OIDC (OpenID Connect) issuer URL. This certificate is required for setting up IAM roles for Kubernetes service accounts.
```bash
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}
```
This resource defines an IAM OpenID Connect Provider for EKS. It configures the provider with necessary client IDs and thumbprint list for certificate validation.

The IAM resources define IAM roles and attach policies required for EKS worker nodes. They allow worker nodes to communicate with the EKS control plane and access other AWS resources.
```bash
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = jsondecode(var.node_group_vpc_config)

  # Other configurations for node groups
}
```
This resource defines an EKS node group for private nodes. It specifies the cluster name, node group name, IAM role for the nodes, and VPC subnet IDs. Other configurations like instance types and scaling options are also specified.

### Terragrunt Configuration for eks
The terragrunt.hcl file contains the inputs for this Terraform configuration. It merges environment-specific variables with region-specific variables to create the necessary configuration for deploying the EKS cluster.
```bash
inputs = merge(
  local.env_vars.inputs,
  local.region_vars.inputs,
  {
    iam_role_name    = "${local.region_vars.inputs.region_shortcode}-${local.env_vars.inputs.environment_shortname}-eks-cluster"
    eks_cluster_name = "${local.region_vars.inputs.region_shortcode}-${local.env_vars.inputs.environment_shortname}-eks"
    ng_role_name     = "${local.region_vars.inputs.region_shortcode}-${local.env_vars.inputs.environment_shortname}-eks-node-group-nodes"
    node_group_name  = "${local.region_vars.inputs.region_shortcode}-${local.env_vars.inputs.environment_shortname}-private-nodes"
    instance_types   = ["t3.small"]
    desired_capacity = 3
    max_capacity     = 5
    min_capacity     = 2
    eks_vpc_config = concat(dependency.vpc.outputs.private_subnet_ids, dependency.vpc.outputs.public_subnet_ids)
    node_group_vpc_config = dependency.vpc.outputs.private_subnet_ids
  }
)
```
## ArgoCD Installation with Terraform and Terragrunt
Navigate to the `deployment/environment/development/us-east-1/argocd` directory containing the Terragrunt configuration file (`terragrunt.hcl`). Update the configuration according to your environment, including dependencies and input variables.
```bash
terraform {
  source = "../../../../../modules/helm-bootstrap-argocd"
}
inputs = merge(
  local.env_vars.inputs,
  local.region_vars.inputs,
  {
  cluster-name = dependency.eks.outputs.cluster_id
  name        = "argocd"
  chart_name  = "argo-cd"
  chart_repository  = "https://argoproj.github.io/argo-helm"
  argo-version     = "5.27.3"
  namespace   = "argocd"
  timeout     = "1200"
#   values_file = [templatefile("./argocd/install.yaml", {})]
  }
)
```
The above terragrunt.hcl file will fetch the argocd module
```bash
data "aws_eks_cluster" "cluster" {
  name = var.cluster-name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster-name
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name       = var.name
  chart      = var.chart_name
  repository = var.chart_repository
  version    = var.argo-version
  namespace  = var.namespace
  timeout    = var.timeout
  values     = [templatefile("./install.yaml", {})]
}
```
 - data "aws_eks_cluster" "cluster": This retrieves information about an AWS EKS cluster named based on the terragrunt.hcl file.
 - data "aws_eks_cluster_auth" "cluster": This retrieves authentication data for the EKS cluster.
 - resource "kubernetes_namespace" "argocd": This creates a Kubernetes namespace named based on the terragrunt.hcl file.
 - resource "helm_release" "argocd": This uses Helm to install ArgoCD. It specifies the name, chart, repository, version, namespace, timeout, and values for the Helm release. The values are loaded from a file named install.yaml


## Accessing ArgoCD UI

Once the Helm chart is deployed using ArgoCD, you can access the ArgoCD UI to manage your deployments. Follow these steps:

1. **Get the ArgoCD URL**: Expose the argocd-server service to access it's UI, by default argocd 
2. **Retrieve Initial Admin Password**: Run the following command to retrieve the initial admin password for ArgoCD:
   
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d
   ```
## Monitoring ArgoCD Applications defined in the application.yaml

To monitor applications in ArgoCD, you can use ArgoCD's Application Custom Resource Definition (CRD) to define and manage applications. Below are the steps to authenticate a Git repository with ArgoCD and synchronize applications:

1. **Authenticate Git Repository**: To authenticate a Git repository with ArgoCD, create a Kubernetes Secret containing the necessary credentials. In the provided `application.yaml` file, a Secret named `private-repo` is created in the `argocd` namespace. This Secret contains the SSH private key required for authenticating with the GitHub repository.

2. **Synchronize Applications**: The `application.yaml` file defines two applications: `argocd` and `go-app`. The `argocd` application synchronizes the ArgoCD Helm chart from the official ArgoCD Helm repository, while the `go-app` application synchronizes the go application from the specified GitHub repository (`github-admin/argocd-deployment`) using Helm.

Ensure that you replace the placeholder values (such as the SSH private key) in the `application.yaml` file with your actual credentials and repository details.

Once the applications are defined in the `application.yaml` file, apply the file to your Kubernetes cluster using the `kubectl apply -f application.yaml` command.

The `application.yaml` is present on the root folder of repo

After applying the `application.yaml` file, ArgoCD will automatically synchronize the defined applications, and you can monitor their status and manage them through the ArgoCD UI.

## Manage additional Application on the EKS cluster using ArgoCD

### Application
The Application CRD is the Kubernetes resource object representing a deployed application instance in an environment. It is defined by two key pieces of information:

 - source reference to the desired state in Git (repository, revision, path, environment)
 - destination reference to the target cluster and namespace. For the cluster one of server or name can be used, but not both (which will result in an error). Under the hood when the server is missing, it is calculated based on the name and used for any operations.

A minimal Application spec is as follows:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
```
You can apply this with kubectl apply -n argocd -f application.yaml and Argo CD will start deploying the guestbook application.

### Repositories
Repository details are stored in secrets. To configure a repo, create a secret which contains repository details. Consider using bitnami-labs/sealed-secrets to store an encrypted secret definition as a Kubernetes manifest. Each repository must have a url field and, depending on whether you connect using HTTPS, SSH, or GitHub App, username and password (for HTTPS), sshPrivateKey (for SSH).

Example for HTTPS:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/argoproj/private-repo
  password: my-password
  username: my-username
```
Example for SSH:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:argoproj/my-private-repository.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
```

### install helmchart 
You can install Helm charts through the UI, or in the declarative GitOps way.
Helm is only used to inflate charts with helm template. The lifecycle of the application is handled by Argo CD instead of Helm. Here is an example:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sealed-secrets
  namespace: argocd
spec:
  project: default
  source:
    chart: sealed-secrets
    repoURL: https://bitnami-labs.github.io/sealed-secrets
    targetRevision: 1.16.1
    helm:
      releaseName: sealed-secrets
  destination:
    server: "https://kubernetes.default.svc"
    namespace: kubeseal
```
#### Values
Argo CD supports the equivalent of a values file directly in the Application manifest using the source.helm.values key.
```yaml
source:
  helm:
    values: |
      ingress:
        enabled: true
        path: /
        hosts:
          - mydomain.example.com
        annotations:
          kubernetes.io/ingress.class: nginx
          kubernetes.io/tls-acme: "true"
        labels: {}
        tls:
          - secretName: mydomain-tls
            hosts:
              - mydomain.example.com
```

