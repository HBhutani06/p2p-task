variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "172.17.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default = true
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default = true
}

variable "map_public_ip_on_launch" {
  description = "A boolean flag to map public IPs on launch for instances in the VPC"
  type        = bool
  default = true
}

variable "name_prefix" {
  description = "A prefix to be added to names of resources created in the VPC"
  type        = string
  default     = "development-vpc"
}

variable "aws_region" {
  description = "The AWS region where the VPC and associated resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "az_names" {
  description = "A list of availability zone names to use for the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}