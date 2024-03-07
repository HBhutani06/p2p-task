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

terraform {
  source = "../../../../../modules/vpc"
}
  
# See source module for input descriptions
inputs = merge(
  local.env_vars.inputs,
  local.region_vars.inputs,
  {

    name_prefix               = "go-app-${local.region_vars.inputs.region_shortcode}-${local.env_vars.inputs.environment_shortname}-eks"
    cidr_block                ="10.0.0.0/16"
    map_public_ip_on_launch   = "true"
    enable_dns_hostnames      = true
    enable_dns_support        = true
    az_names                  = ["us-east-1a", "us-east-1b"]
  }
)