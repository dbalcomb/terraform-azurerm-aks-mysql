output "name" {
  description = "The service name"
  value       = var.name
}

output "namespace" {
  description = "The service namespace"
  value       = kubernetes_namespace.main.metadata.0.name
}

output "region" {
  description = "The target region"
  value       = var.region
}

output "port" {
  description = "The service port"
  value       = 3306
}

output "external_name" {
  description = "The external service name"
  value       = format("%s.%s.svc.cluster.local", kubernetes_service.main.metadata.0.name, kubernetes_service.main.metadata.0.namespace)
}

output "root_password" {
  description = "The service root password"
  value       = random_password.root.result
  sensitive   = true
}
