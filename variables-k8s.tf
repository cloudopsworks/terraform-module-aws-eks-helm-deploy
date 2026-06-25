##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# namespace: "apps" # (Required) Kubernetes namespace where the Helm release and optional Kubernetes resources are managed.
variable "namespace" {
  description = "Kubernetes namespace where the Helm release and optional Kubernetes resources are managed."
  type        = string
}

# release: # (Required) Helm release metadata used by resources and labels. Default: {}.
#   name: "my-app"                 # (Required) Helm release name.
#   version: "1.2.3"               # (Optional) Application/chart version used for local chart labels and remote chart version when release.source.version is unset. Default: "".
#   source:                         # (Optional) Source metadata for remote chart deployments. Default: {}.
#     version: "1.2.3"             # (Optional) Helm chart version for repository-backed releases; takes precedence over release.version. Default: "".
variable "release" {
  description = "Helm release metadata used by resources and labels."
  type        = any
  default     = {}
}

# helm_repo_url: "" # (Optional) Helm repository URL. Leave empty to deploy a local chart from helm_chart_path or absolute_path/helm/charts. OCI repositories are supported. Default: "".
variable "helm_repo_url" {
  description = "Helm repository URL. Leave empty to deploy a local chart from helm_chart_path or absolute_path/helm/charts."
  type        = string
  default     = ""
}

# helm_chart_name: "" # (Optional) Chart name to install when helm_repo_url is set. Default: "".
variable "helm_chart_name" {
  description = "Chart name to install when helm_repo_url is set."
  type        = string
  default     = ""
}

# helm_chart_path: "" # (Optional) Local chart path used when helm_repo_url is empty; defaults to absolute_path/helm/charts when empty. Default: "".
variable "helm_chart_path" {
  description = "Local chart path used when helm_repo_url is empty; defaults to absolute_path/helm/charts when empty."
  type        = string
  default     = ""
}

# values_file: "values.yaml" # (Required) Values file path. Repository-backed charts are read from absolute_path/values_file; local charts use the path as provided.
variable "values_file" {
  description = "Values file path. Repository-backed charts are read from absolute_path/values_file; local charts use the path as provided."
  type        = string
}

# values_overrides: {} # (Optional) Helm set overrides merged with secret/config mount overrides. Values are sent as string set entries. Default: {}.
#   image.tag: "1.2.3" # (Optional) Example Helm value override key and value.
variable "values_overrides" {
  description = "Helm set overrides merged with secret/config mount overrides. Values are sent as string set entries."
  type        = any
  default     = {}
}

# absolute_path: "." # (Optional) Base path for values and injected file folders. Default: ".".
variable "absolute_path" {
  description = "Base path for values and injected file folders."
  type        = string
  default     = "."
}

# config_map: # (Optional) ConfigMap file injection settings. Default: {}.
#   enabled: false          # (Optional) Create a ConfigMap from files under absolute_path/values/files_path. Default: false.
#   files_path: "config"    # (Optional) Folder below absolute_path/values containing ConfigMap files. Default: "".
#   mount_point: "/config"  # (Optional) Pod mount path injected through Helm overrides. Default: "".
variable "config_map" {
  description = "ConfigMap file injection settings."
  type        = any
  default     = {}
}

# secret_files: # (Optional) Secret file injection settings. Files are rendered as templates with pulled Secrets Manager values. Default: {}.
#   enabled: false           # (Optional) Create a Kubernetes Secret from files under absolute_path/values/files_path. Default: false.
#   files_path: "secrets"    # (Optional) Folder below absolute_path/values containing secret templates. Default: "".
#   mount_point: "/secrets"  # (Optional) Pod mount path injected through Helm overrides. Default: "".
variable "secret_files" {
  description = "Secret file injection settings. Files are rendered as templates with pulled Secrets Manager values."
  type        = any
  default     = {}
}

# secrets: # (Optional) AWS Secrets Manager pull and External Secrets Operator settings. Default: {}.
#   secrets_path_filter: []                 # (Optional) List of AWS Secrets Manager name filters/prefixes to read. Default: [].
#   external_secrets:                       # (Optional) External Secrets Operator configuration. Default: {}.
#     enabled: false                        # (Optional) Create an ExternalSecret instead of a native Kubernetes Secret. Default: false.
#     create_store: false                   # (Optional) Create a SecretStore in the target namespace. Default: false.
#     store_name: "external-secrets-store"  # (Optional) Existing SecretStore name when create_store is false. Default: "".
#     refresh_interval: "1h"                # (Optional) ExternalSecret refresh interval for Periodic refreshPolicy. Default: "1h".
#     on_change: false                      # (Optional) Use OnChange refreshPolicy instead of Periodic. Default: false.
variable "secrets" {
  description = "AWS Secrets Manager pull and External Secrets Operator settings."
  type        = any
  default     = {}
}

# create_namespace: false # (Optional) Create the Kubernetes namespace when true; otherwise the namespace must already exist. Default: false.
variable "create_namespace" {
  description = "Create the Kubernetes namespace when true; otherwise the namespace must already exist."
  type        = bool
  default     = false
}

# namespace_annotations: {} # (Optional) Annotations applied to the namespace when create_namespace is true. Default: {}.
#   example.com/owner: "platform"
variable "namespace_annotations" {
  description = "Annotations applied to the namespace when create_namespace is true."
  type        = any
  default     = {}
}

# timeout: 300 # (Optional) Timeout in seconds for Helm release operations. Default: 300.
variable "timeout" {
  description = "Timeout in seconds for Helm release operations."
  type        = number
  default     = 300
}
