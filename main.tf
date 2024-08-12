##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

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
    for_each = var.values_overrides

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
    for_each = var.values_overrides

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