##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "namespace" {
  description = "Namespace for the resources"
  type        = string
}

# variable "repository_owner" {
#   description = "Owner of the repository"
#   type        = string
# }

variable "release" {
  description = "Release configuration"
  type        = any
  default     = {}
}
# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
# }

variable "helm_repo_url" {
  description = "URL of the Helm repository"
  type        = string
  default     = ""
}

variable "helm_chart_name" {
  description = "Name of the Helm chart"
  type        = string
  default     = ""
}

variable "helm_chart_path" {
  description = "Path to the Helm chart"
  type        = string
  default     = ""
}

variable "values_file" {
  description = "Path to the values file"
  type        = string
}

variable "values_overrides" {
  description = "Values to be passed to the Helm chart"
  type        = any
  default     = {}
}

variable "absolute_path" {
  description = "Absolute path of the current directory"
  type        = string
  default     = "."
}

variable "config_map" {
  description = "ConfigMap to be created"
  type        = any
  default     = {}
}

variable "secret_files" {
  description = "Secret files to be injected into a folder alongside with 'secrets' variable templating"
  type        = any
  default     = {}
}

variable "secrets" {
  description = "Secrets to be pulled from AWS Secrets Manager"
  type        = any
  default     = {}
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = bool
  default     = false
}

variable "namespace_annotations" {
  description = "Annotations for the namespace"
  type        = any
  default     = {}
}

variable "external_secrets" {
  description = "(optional) External Secrets configuration object, required if external_secrets_enabled is true"
  type = object({
    enabled          = optional(bool, false)
    create_store     = optional(bool, false)
    store_name       = optional(string, "")
    refresh_interval = optional(string, "1h")
  })
  default = {}
}

variable "external_secrets_store_name" {
  description = "(optional) Name of the External Secrets Store, required if external_secrets_enabled is true, and extenal_secrets_create_store is false"
  type        = string
  default     = ""
}
