# Test
# https://opentofu.org/docs/cli/commands/test

mock_provider "helm" {}

run "default_regional" {
  command = apply

  module {
    source = "./tests/fixtures/default/regional"
  }

  assert {
    condition     = output.namespace == "kagent" && output.ui_service_port == 8080
    error_message = "The module must expose the supplied namespace and the kagent UI port."
  }
}

run "substrate_and_tags" {
  command = plan

  module {
    source = "./regional"
  }

  override_module {
    target = module.core_helpers
    outputs = {
      env         = "prod"
      environment = "production"
      region      = "us-east1"
      zone        = "b"
    }
  }

  variables {
    llm_base_url        = "http://agentgateway-proxy.agentgateway.svc.cluster.local/v1"
    namespace           = "kagent"
    substrate_namespace = "ate-system"
  }

  assert {
    condition = (
      yamldecode(helm_release.kagent.values[0]).config.substrate.apiEndpoint == "dns:///api.ate-system.svc:443" &&
      yamldecode(helm_release.kagent.values[0]).substrateWorkerPool.create == true &&
      yamldecode(helm_release.kagent.values[0]).substrateWorkerPool.workerImage == "ghcr.io/kagent-dev/substrate/ateworker-gvisor:v1.0.1"
    )
    error_message = "kagent must target the Agent Substrate API in its namespace and create a worker pool with the matching worker image."
  }

  assert {
    condition     = yamldecode(helm_release.kagent.values[0]).providers.openAI.config.baseUrl == "http://agentgateway-proxy.agentgateway.svc.cluster.local/v1"
    error_message = "llm_base_url must route the default model through the supplied gateway."
  }

  assert {
    condition = yamldecode(helm_release.kagent.values[0]).podLabels == {
      "tags.datadoghq.com/env"     = "production"
      "tags.datadoghq.com/service" = "kagent"
      "tags.datadoghq.com/version" = var.kagent_version
    }
    error_message = "kagent pod templates must carry full unified service tags."
  }

  assert {
    condition = (
      yamldecode(helm_release.kagent.values[0]).database.postgres.ownerConnectionStringSecretRef.name == "kagent-postgres-owner" &&
      yamldecode(helm_release.kagent.values[0]).database.postgres.readWriteConnectionStringSecretRef.name == "kagent-postgres-readwrite"
    )
    error_message = "kagent must read its PostgreSQL connection strings from the existing Secrets."
  }
}

run "fractional_worker_replicas_rejected" {
  command = plan

  module {
    source = "./regional"
  }

  variables {
    namespace            = "kagent"
    substrate_namespace  = "ate-system"
    worker_pool_replicas = 1.5
  }

  expect_failures = [var.worker_pool_replicas]
}
