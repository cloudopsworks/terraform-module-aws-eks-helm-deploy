## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.35 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.38 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.35 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.38 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [helm_release.default](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.repo](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_annotations.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_config_map.config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_labels.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/labels) | resource |
| [kubernetes_manifest.external_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.external_secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.secret_files](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret_version.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secrets.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secrets) | data source |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_absolute_path"></a> [absolute\_path](#input\_absolute\_path) | Base path for values and injected file folders. | `string` | `"."` | no |
| <a name="input_config_map"></a> [config\_map](#input\_config\_map) | ConfigMap file injection settings. | `any` | `{}` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the Kubernetes namespace when true; otherwise the namespace must already exist. | `bool` | `false` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags merged with generated Cloud Ops Works common tags. | `map(string)` | `{}` | no |
| <a name="input_helm_chart_name"></a> [helm\_chart\_name](#input\_helm\_chart\_name) | Chart name to install when helm\_repo\_url is set. | `string` | `""` | no |
| <a name="input_helm_chart_path"></a> [helm\_chart\_path](#input\_helm\_chart\_path) | Local chart path used when helm\_repo\_url is empty; defaults to absolute\_path/helm/charts when empty. | `string` | `""` | no |
| <a name="input_helm_repo_url"></a> [helm\_repo\_url](#input\_helm\_repo\_url) | Helm repository URL. Leave empty to deploy a local chart from helm\_chart\_path or absolute\_path/helm/charts. | `string` | `""` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Indicates whether this deployment belongs to a hub configuration. | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where the Helm release and optional Kubernetes resources are managed. | `string` | n/a | yes |
| <a name="input_namespace_annotations"></a> [namespace\_annotations](#input\_namespace\_annotations) | Annotations applied to the namespace when create\_namespace is true. | `any` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization context used by naming and tagging. | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_release"></a> [release](#input\_release) | Helm release metadata used by resources and labels. | `any` | `{}` | no |
| <a name="input_secret_files"></a> [secret\_files](#input\_secret\_files) | Secret file injection settings. Files are rendered as templates with pulled Secrets Manager values. | `any` | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | AWS Secrets Manager pull and External Secrets Operator settings. | `any` | `{}` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Three-digit spoke identifier used in generated names. | `string` | `"001"` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in seconds for Helm release operations. | `number` | `300` | no |
| <a name="input_values_file"></a> [values\_file](#input\_values\_file) | Values file path. Repository-backed charts are read from absolute\_path/values\_file; local charts use the path as provided. | `string` | n/a | yes |
| <a name="input_values_overrides"></a> [values\_overrides](#input\_values\_overrides) | Helm set overrides merged with secret/config mount overrides. Values are sent as string set entries. | `any` | `{}` | no |

## Outputs

No outputs.
