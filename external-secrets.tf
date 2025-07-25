##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# External Secrets will rely on External Secrets Operator installed in the cluster.
# The access to AWS Secrets Manager is managed through the IAM role associated with the Kubernetes service account.
locals {
  external_secrets_data = flatten([
    for key, secret in local.secrets_map : [
      for ent, value in tomap(jsondecode(data.aws_secretsmanager_secret_version.secret[key].secret_string)) : [
        startswith(data.aws_secretsmanager_secret_version.secret[key].secret_string, "{") ? {
          secretKey = "${lower(secret.filtered_key)}_${lower(ent)}"
          remoteRef = {
            key      = secret.secret_name
            property = ent
          }
          } : {
          secretKey = secret.filtered_key
          remoteRef = {
            key = secret.secret_name
          }
        }
      ]
    ]
  ])
}

resource "kubernetes_manifest" "external_secret_store" {
  count = local.external_secrets_enabled && local.external_secrets_create_store && length(local.secrets_path_filter) > 0 ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "${var.release.name}-external-secret-store"
      namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
    }
    spec = {
      provider = {
        aws = {
          region  = data.aws_region.current.id
          service = "SecretsManager"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "external_secret" {
  count = local.external_secrets_enabled && length(local.secrets_path_filter) > 0 ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "${var.release.name}-external-secret"
      namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
    }
    spec = {
      refreshPolicy   = try(var.secrets.external_secrets.on_change, false) ? "OnChange" : "Periodic"
      refreshInterval = try(var.secrets.external_secrets.refresh_interval, "1h")
      secretStoreRef = {
        kind = "SecretStore"
        name = local.external_secrets_create_store ? kubernetes_manifest.external_secret_store[0].object.metadata[0].name : var.secrets.external_secrets.store_name
      }
      target = {
        name            = "${var.release.name}-external-secret"
        creationPolicy  = "Owner"
        deleteionPolicy = "Retain"
      }
      data = local.external_secrets_data
    }
  }
}