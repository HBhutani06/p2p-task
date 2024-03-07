module "eks-addons" {
  source = "particuleio/addons/kubernetes"
  version = "15.2.0"

  cert-manager                 = var.cert-manager
  external-dns                 = var.external-dns
  priority-class               = var.priority-class
  priority-class-ds            = var.priority-class-ds
  cluster-name                 = var.cluster-name
  traefik                      = var.traefik
  sealed-secrets               = var.sealed-secrets
  flux2                        = var.flux2
  cluster-autoscaler = var.cluster-autoscaler
  ingress-nginx = var.ingress-nginx
  # aws-ebs-csi-driver = var.aws-ebs-csi-driver
  metrics-server = var.metrics-server


}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster-name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster-name
}

terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}