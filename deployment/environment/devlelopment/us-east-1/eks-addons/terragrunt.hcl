include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

include "region" {
  path = find_in_parent_folders("region.hcl")
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}


dependency "eks" {
  config_path = "../eks"

  mock_outputs = { # Mock outputs supplied to allow "plan" stages to progress without error. https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency
    eks_oidc_issuer_url  = "temp-cluster_oidc_issuer_url"
    cluster_id              = "temp-cluster_id"
  }
}

dependencies {
  paths = ["../eks", "../vpc"]
}

terraform {
  source = "../../../../../modules/eks-addons"
}

# # #See source module for input descriptions
inputs = merge(
  local.env_vars.inputs,
  local.region_vars.inputs,
  {


    cluster-name = dependency.eks.outputs.cluster_id
    cluster-name = "ue1-dev-eks"
    eks = {
      "cluster_oidc_issuer_url" = dependency.eks.outputs.eks_oidc_issuer_url
    }

    aws-load-balancer-controller = {
      enabled = true
    }

    cluster-autoscaler = {
      enabled = true
    }

    cert-manager = {
      enabled = true
    }

    ingress-nginx = {
      enabled = true
    }

    aws-ebs-csi-driver = {
      enabled = true
    }

    metrics-server = {
      enabled = true
    }

    sealed-secrets = {
      enabled = true
    }

  }
)