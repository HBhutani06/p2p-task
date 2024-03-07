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
  config_path = "../eks/"

  mock_outputs = { # Mock outputs supplied to allow "plan" stages to progress without error. https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency
    cluster_id = "temp-cluster_id"
  }
}

dependencies {
  paths = ["../eks"]
}

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