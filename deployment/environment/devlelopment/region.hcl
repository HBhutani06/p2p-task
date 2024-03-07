generate "region_vars" {
  path      = "terraform.tfvars"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    region = "us-east-1"
EOF
}

inputs = {
  region_longname  = "us-east-1"
  region_shortcode = "ue1"
}