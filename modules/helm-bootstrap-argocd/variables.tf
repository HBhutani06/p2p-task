variable "cluster-name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}

variable "namespace" {
  description = "The namespace name where the sealed secret chart will be installed. If 'create_namespace' is 'true', a Namespace with the provided value will be created, otherwise, it will assume the namespace with this name already exist"
  type        = string
}

variable "chart_name" {
  type        = string
  description = "Name of the helm chart"

}
variable "chart_repository" {
  description = "The sealed secrets chart repository"
  type        = string

  default = "https://charts.fluxcd.io"
}

variable "argo-version" {
  default = "5.27.3"
}

variable "name" {
  type        = string
  description = "Helm deployment name"
}

variable "timeout" {
  description = "Timeout for Helm operation"
  type        = string
}
