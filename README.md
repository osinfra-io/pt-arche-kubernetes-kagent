# Kubernetes kagent OpenTofu Module

[![OpenTofu Tests](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-kubernetes-kagent/test.yml?style=for-the-badge&logo=opentofu&color=FEDA15&label=OpenTofu%20Tests)](https://github.com/osinfra-io/pt-arche-kubernetes-kagent/actions/workflows/test.yml) [![Dependabot](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-kubernetes-kagent/dependabot.yml?style=for-the-badge&logo=github&color=2088FF&label=Dependabot)](https://github.com/osinfra-io/pt-arche-kubernetes-kagent/actions/workflows/dependabot.yml) [![Datadog Security Enabled](https://img.shields.io/badge/Datadog%20Security-Enabled-632CA6?style=for-the-badge&logo=datadog)](https://app.datadoghq.com/security/code-security/repositories?repository_id=pt-arche-kubernetes-kagent)

## Repository Description

Reusable OpenTofu child module that installs kagent (`kagent-crds` and `kagent` Helm charts) on GKE with the Agent Substrate integration and a default worker pool, so agents can run in sandboxed actors. Setting `llm_base_url` routes the default model through the internal [agentgateway](https://github.com/osinfra-io/pt-arche-kubernetes-agentgateway) proxy instead of calling the LLM provider directly.

## 🔩 Usage

Deploy [`pt-arche-kubernetes-agent-substrate`](https://github.com/osinfra-io/pt-arche-kubernetes-agent-substrate) first and pass its namespace as `substrate_namespace`. Create the kagent namespace in the consuming root and pass its name explicitly, labelled `ate.dev/api-access=true`: Substrate's default-deny NetworkPolicies admit API clients only from namespaces with that label, and without it the controller cannot reach the API. The controller identity (`spiffe://cluster.local/ns/<namespace>/sa/kagent-controller`) must also be listed in the Agent Substrate module's `ingress_allowed_spiffe_ids`, otherwise the router denies all actor ingress. The module mounts the controller's Substrate client certificate (`controller.substrateClientCertificate`) so it can authenticate to the API.

Like the authentik module, this module uses external PostgreSQL and existing Secrets: `postgres_owner_secret_name` and `postgres_read_write_secret_name` name Secrets whose `ownerConnectionString` and `readWriteConnectionString` keys hold the connection strings. The default model's API key Secret (`kagent-openai`) must also exist; this module creates none of them. The worker image tag follows `substrate_version`, so keep it aligned with the Agent Substrate release.

> [!TIP]
> You can check the [tests/fixtures](tests/fixtures) directory for example configurations. These fixtures set up the system for testing by providing all the necessary initial code, thus creating good examples on which to base your configurations.

## 🛠️ Tools

- [Helm](https://github.com/helm/helm)
- [kagent](https://kagent.dev/docs/kagent)
- [osinfra-pre-commit-hooks](https://github.com/osinfra-io/pt-techne-pre-commit-hooks)
- [pre-commit](https://github.com/pre-commit/pre-commit)

## 📋 Skills and Knowledge

Links to documentation and other resources required to develop and iterate in this repository successfully.

- [kagent](https://kagent.dev/docs/kagent)
- [kagent with agentgateway](https://kagent.dev/docs/kagent/0.x/examples/agentgateway/)
- [kagent on Agent Substrate](https://kagent.dev/docs/kagent/0.x/examples/agent-substrate/)

## 🔍 Tests

All OpenTofu tests are [mocked](https://opentofu.org/docs/cli/commands/test/#the-mock_provider-blocks) allowing us to test the module without creating infrastructure or requiring credentials. The trade-offs are acceptable in favor of speed and simplicity. In an OpenTofu test, a mocked provider or resource will generate fake data for all computed attributes that would normally be provided by the underlying provider APIs.

```none
tofu init
tofu test
```

## 📦 Release

Push a semantic version tag after tests pass:

```none
git tag vX.Y.Z
git push origin vX.Y.Z
```
