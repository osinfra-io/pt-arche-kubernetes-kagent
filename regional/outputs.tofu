# Output Values
# https://opentofu.org/docs/language/values/outputs

output "namespace" {
  description = "Namespace containing kagent"
  value       = var.namespace
}

output "ui_service_name" {
  description = "Name of the kagent UI service"
  value       = "kagent-ui"
}

output "ui_service_port" {
  description = "Port exposed by the kagent UI service"
  value       = 8080
}
