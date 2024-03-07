variable "iam_role_name" {
  description = "Name for the IAM role used by EKS"
  type        = string
  default     = "eks-cluster-demo"
}

variable "eks_cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "development-eks"
}

variable "ng_role_name" {
  description = "Name for the IAM role used by EKS worker nodes"
  type        = string
    default = "eks-node-group-nodes"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default = "private-nodes"
}

variable "eks_vpc_config" {
  description = "Configuration for the EKS cluster VPC"
  type        = any
}

variable "node_group_vpc_config" {
  description = "Configuration for the node group VPC"
  type        = any
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_capacity" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}
