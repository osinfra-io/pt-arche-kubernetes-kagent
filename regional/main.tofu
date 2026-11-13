# Helm Release
# https://search.opentofu.org/provider/hashicorp/helm/latest/docs/resources/release

resource "helm_release" "kagent" {
  depends_on = [
    helm_release.kagent_crds
  ]

  chart     = local.kagent_chart
  name      = "kagent"
  namespace = var.namespace

  values = [
    local.kagent_helm_values
  ]

  version = var.kagent_version
}

resource "helm_release" "kagent_crds" {
  chart     = local.kagent_crds_chart
  name      = "kagent-crds"
  namespace = var.namespace
  version   = var.kagent_version
}
