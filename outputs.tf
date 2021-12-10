output "namespace" {
  description = "The resource namespace"
  value       = kubernetes_namespace.main.metadata.0.name
}
