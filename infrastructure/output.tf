output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "alb_dns" {
  value = aws_lb.phoenix.dns_name
}
