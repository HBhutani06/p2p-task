output "eks_cluster_name" {
  description = "Name of the created EKS cluster"
  value       = aws_eks_cluster.demo.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the created EKS cluster"
  value       = aws_eks_cluster.demo.endpoint
}

output "eks_cluster_security_group_ids" {
  description = "Security group IDs associated with the EKS cluster"
  value       = aws_eks_cluster.demo.vpc_config[0].cluster_security_group_id
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  value       = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

output "eks_node_group_name" {
  description = "Name of the created EKS node group"
  value       = aws_eks_node_group.private-nodes.node_group_name
}

output "cluster_id" {
  value = aws_eks_cluster.demo.id
}