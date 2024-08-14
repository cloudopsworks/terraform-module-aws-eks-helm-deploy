##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  secrets_path_filter = try(var.secrets.secrets_path_filter, [])
  secrets_overrides = length(local.secrets_path_filter) > 0 ? {
    "envFrom[0].secretRef.name" = kubernetes_secret.secrets[0].metadata[0].name
  } : {}
  all_overrides = merge(var.values_overrides, local.secrets_overrides)
}

data "kubernetes_namespace" "this" {
  count = var.create_namespace ? 0 : 1
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "repo" {
  count            = var.helm_repo_url != "" ? 1 : 0
  name             = var.release.name
  chart            = var.helm_chart_name
  repository       = var.helm_repo_url
  namespace        = var.create_namespace ? var.namespace : data.kubernetes_namespace.this[0].metadata.0.name
  create_namespace = var.create_namespace
  version          = startswith(var.helm_repo_url, "oci") ? null : try(var.release.version, null)
  wait             = true

  values = [
    file("${var.absolute_path}/${var.values_file}")
  ]

  dynamic "set" {
    for_each = local.all_overrides

    content {
      name  = set.key
      value = replace(set.value, ",", "\\,")
      type  = "string"
    }
  }

  #   dynamic "set_sensitive" {
  #     for_each = var.sensitive_vars
  #
  #     content {
  #       name  = set_sensitive.key
  #       value = replace(set_sensitive.value, ",", "\\,")
  #       type  = "string"
  #     }
  #   }
}

resource "helm_release" "default" {
  count            = var.helm_repo_url == "" ? 1 : 0
  name             = var.release.name
  chart            = var.helm_chart_path == "" ? "${var.absolute_path}/helm/charts" : var.helm_chart_path
  namespace        = var.create_namespace ? var.namespace : data.kubernetes_namespace.this[0].metadata.0.name
  create_namespace = var.create_namespace
  wait             = true

  values = [
    file(var.values_file)
  ]

  dynamic "set" {
    for_each = local.all_overrides

    content {
      name  = set.key
      value = replace(set.value, ",", "\\,")
      type  = "string"
    }
  }

  #   dynamic "set_sensitive" {
  #     for_each = var.sensitive_vars
  #
  #     content {
  #       name  = set_sensitive.key
  #       value = replace(set_sensitive.value, ",", "\\,")
  #       type  = "string"
  #     }
  #   }
}