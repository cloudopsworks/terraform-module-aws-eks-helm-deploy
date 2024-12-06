##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "aws_secretsmanager_secrets" "secrets" {
  for_each = toset(local.secrets_path_filter)
  filter {
    name   = "name"
    values = [each.value]
  }
}

locals {
  secrets_map = merge([
    for prefix in toset(local.secrets_path_filter) : {
      for secret_name in data.aws_secretsmanager_secrets.secrets[prefix].names : replace(replace(secret_name, "/", "|"), replace("${prefix}/", "/", "|"), "") => {
        secret_id = secret_name
        prefix    = prefix
      }
    }
  ]...)

  secrets_plain = {
    for k, v in local.secrets_map : k => data.aws_secretsmanager_secret_version.secret[k].secret_string
    if !startswith(data.aws_secretsmanager_secret_version.secret[k].secret_string, "{")
  }

  secrets_json = merge([
    for key, secret in local.secrets_map : {
      for ent, value in tomap(jsondecode(data.aws_secretsmanager_secret_version.secret[key].secret_string)) :
      "${key}_${ent}" => value
    }
    if startswith(data.aws_secretsmanager_secret_version.secret[key].secret_string, "{")
  ]...)
}

data "aws_secretsmanager_secret_version" "secret" {
  for_each  = local.secrets_map
  secret_id = each.value.secret_id
}

resource "kubernetes_secret" "secrets" {
  count = length(local.secrets_path_filter) > 0 ? 1 : 0
  metadata {
    name      = "${var.release.name}-injected-secrets"
    namespace = var.namespace
  }
  data = merge(local.secrets_plain, local.secrets_json)
}