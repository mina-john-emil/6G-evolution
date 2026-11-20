output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "region" {
  value = local.region
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${local.region} --name ${module.eks.cluster_name}"
}
