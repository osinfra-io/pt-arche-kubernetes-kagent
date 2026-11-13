# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "chart_repository" {
  description = "OCI repository containing the kagent Helm charts"
  type        = string
  default     = "oci://ghcr.io/kagent-dev/kagent/helm"
}

variable "kagent_version" {
  description = "kagent Helm chart version"
  type        = string
  default     = "1.0.1"
}

variable "labels" {
  description = "Labels applied to kagent resources"
  type        = map(string)
  default     = {}
}

variable "llm_base_url" {
  description = "Base URL for the default OpenAI-compatible model, e.g. the internal agentgateway proxy; null calls the provider directly"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace for kagent"
  type        = string
}

variable "postgres_owner_secret_name" {
  description = "Existing Secret whose ownerConnectionString key holds the PostgreSQL owner connection string; the owner creates the schema and runs migrations"
  type        = string
  default     = "kagent-postgres-owner"
}

variable "postgres_read_write_secret_name" {
  description = "Existing Secret whose readWriteConnectionString key holds the PostgreSQL read/write connection string used for runtime queries"
  type        = string
  default     = "kagent-postgres-readwrite"
}

variable "substrate_namespace" {
  description = "Kubernetes namespace where Agent Substrate is installed"
  type        = string
}

variable "substrate_version" {
  description = "Agent Substrate version, used to select the matching worker image tag"
  type        = string
  default     = "1.0.1"
}

variable "worker_image_repository" {
  description = "Agent Substrate gVisor worker image repository, without a tag"
  type        = string
  default     = "ghcr.io/kagent-dev/substrate/ateworker-gvisor"
}

variable "worker_pool_replicas" {
  description = "Number of Agent Substrate workers; each long-lived harness pins one"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_pool_replicas > 0 && floor(var.worker_pool_replicas) == var.worker_pool_replicas
    error_message = "worker_pool_replicas must be a whole number greater than zero."
  }
}
