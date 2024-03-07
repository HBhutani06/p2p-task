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

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = { # Mock outputs supplied to allow "plan" stages to progress without error. https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency
    vpc_id          = "temp-vpc-id"
    public_subnets  = ["temp-subnet1", "temp-subnet2"]
    private_subnets = ["temp-subnet3", "temp-subnet4"]
  }
}



terraform {
  source = "../../../../../modules/eks"
}
  
# See source module for input descriptions
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