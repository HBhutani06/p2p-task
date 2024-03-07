variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "repository_force_delete" {
  description = "Whether to force delete the repository"
  type        = bool
  default     = false
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to enable image scanning on push"
  type        = bool
  default     = true
}