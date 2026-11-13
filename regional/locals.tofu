# Local Values
# https://opentofu.org/docs/language/values/locals

locals {
  kagent_chart      = "${var.chart_repository}/kagent"
  kagent_crds_chart = "${var.chart_repository}/kagent-crds"

  kagent_helm_values = yamlencode({
    database = {
      postgres = {
        ownerConnectionStringSecretRef = {
          key  = "ownerConnectionString"
          name = var.postgres_owner_secret_name
        }
        readWriteConnectionStringSecretRef = {
          key  = "readWriteConnectionString"
          name = var.postgres_read_write_secret_name
        }
      }
    }

    config = {
      substrate = {
        actorJwtIssuer = "https://idp.${var.substrate_namespace}.svc"
        apiEndpoint    = "dns:///api.${var.substrate_namespace}.svc:443"
        routerUrl      = "https://atenet-router.${var.substrate_namespace}.svc:443"
      }
    }

    controller = {
      substrateClientCertificate = {
        enabled = true
      }
    }

    labels = var.labels

    podLabels = merge(var.labels, {
      "tags.datadoghq.com/env"     = module.core_helpers.environment
      "tags.datadoghq.com/service" = "kagent"
      "tags.datadoghq.com/version" = var.kagent_version
    })

    providers = {
      default = "openAI"
      openAI = {
        config = local.llm_provider_config
      }
    }

    substrateWorkerPool = {
      create      = true
      replicas    = var.worker_pool_replicas
      workerImage = local.worker_image
    }
  })

  llm_provider_config = var.llm_base_url == null ? null : {
    baseUrl = var.llm_base_url
  }

  worker_image = "${var.worker_image_repository}:v${var.substrate_version}"
}
