module "kagent" {
  source = "../../../../regional"

  namespace           = "kagent"
  substrate_namespace = "ate-system"
}

output "namespace" {
  value = module.kagent.namespace
}

output "ui_service_port" {
  value = module.kagent.ui_service_port
}
