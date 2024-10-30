##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  secrets_path_filter = try(var.secrets.secrets_path_filter, [])
  secrets_overrides = length(local.secrets_path_filter) > 0 ? {
    "injectEnvFrom[0].secretRef.name" = kubernetes_secret.secrets[0].metadata[0].name
  } : {}
  all_overrides   = merge(var.values_overrides, local.secrets_overrides, local.mount_overrides)
  source_version  = try(var.release.source.version, "")
  app_version     = try(var.release.version, "")
  release_version = coalesce(local.source_version, local.app_version, "NA")
}

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "kubernetes_labels" "this" {
  count       = var.create_namespace ? 1 : 0
  api_version = "v1"
  kind        = "Namespace"
  force       = true
  metadata {
    name = kubernetes_namespace.this[count.index].metadata[0].name
  }
  labels = {
    "app.kubernetes.io/name"       = var.release.name
    "app.kubernetes.io/version"    = replace(local.release_version, "+", "-")
    "app.kubernetes.io/managed-by" = "Terraform"
  }
}

resource "kubernetes_annotations" "this" {
  count       = var.create_namespace ? 1 : 0
  api_version = "v1"
  kind        = "Namespace"
  force       = true
  metadata {
    name = kubernetes_namespace.this[count.index].metadata[0].name
  }
  annotations = var.namespace_annotations
}


data "kubernetes_namespace" "this" {
  count = var.create_namespace ? 0 : 1
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_annotations" "ns_annotations" {
  count       = var.create_namespace ? 0 : 1
  api_version = "v1"
  kind        = "Namespace"
  force       = true
  metadata {
    name = data.kubernetes_namespace.this[count.index].metadata[0].name
  }
  annotations = var.namespace_annotations
}

resource "kubernetes_labels" "ns_labels" {
  count       = var.create_namespace ? 0 : 1
  api_version = "v1"
  kind        = "Namespace"
  force       = true
  metadata {
    name = data.kubernetes_namespace.this[count.index].metadata[0].name
  }
  labels = {
    "app.kubernetes.io/name"       = var.release.name
    "app.kubernetes.io/version"    = local.release_version
    "app.kubernetes.io/managed-by" = "Terraform"
  }
}


resource "helm_release" "repo" {
  count            = var.helm_repo_url != "" ? 1 : 0
  name             = var.release.name
  chart            = var.helm_chart_name
  repository       = var.helm_repo_url
  namespace        = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
  create_namespace = var.create_namespace
  version          = startswith(var.helm_repo_url, "oci") || local.release_version == "NA" ? null : local.release_version
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
  namespace        = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
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