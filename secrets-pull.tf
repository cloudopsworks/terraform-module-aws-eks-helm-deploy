##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "aws_secretsmanager_secrets" "secrets" {
  for_each = toset(var.secrets.secrets_path_filter)
  filter {
    name   = "name"
    values = [each.value]
  }
}

locals {
  secrets_map = merge([
    for prefix in toset(var.secrets.secrets_path_filter) : {
      for secret_name in data.aws_secretsmanager_secrets.secrets[prefix].names : replace(secret_name, "${prefix}/", "") => {
        secret_id = secret_name
        prefix    = prefix
      }
    }
  ]...)
}

data "aws_secretsmanager_secret_version" "secret" {
  for_each  = local.secrets_map
  secret_id = each.value.secret_id
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = var.release.name
    namespace = var.namespace
  }
  data = {
    for k, v in local.secrets_map : k => data.aws_secretsmanager_secret_version.secret[k].secret_string
  }
}