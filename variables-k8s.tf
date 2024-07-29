##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "namespace" {
  description = "Namespace for the resources"
  type        = string
}

variable "repository_owner" {
  description = "Owner of the repository"
  type        = string
}

variable "release" {
  description = "Release configuration"
  type        = any
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

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

variable "values" {
  description = "Values to be passed to the Helm chart"
  type        = any
}

variable "absolute_path" {
  description = "Absolute path of the current directory"
  type        = string
  default     = "."
}