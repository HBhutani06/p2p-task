output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.my_ecr_repo.name
}