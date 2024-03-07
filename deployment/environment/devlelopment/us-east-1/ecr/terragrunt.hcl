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
  source = "../../../../../modules/ecr"
}
  
# See source module for input descriptions
inputs = merge(
  local.env_vars.inputs,
  local.region_vars.inputs,
  {
    ecr_name                = "${local.region_vars.inputs.region_shortcode}-${local.env_vars.inputs.environment_shortname}-ecr"
    repository_force_delete = true
    image_tag_mutability    = "MUTABLE"
    scan_on_push            = true
  }
)