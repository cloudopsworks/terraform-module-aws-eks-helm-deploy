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
  secrets_map_pre = merge([
    for prefix in toset(local.secrets_path_filter) : {
      for secret_name in data.aws_secretsmanager_secrets.secrets[prefix].names : secret_name => {
        secret_name  = secret_name
        prefix       = prefix
        filtered_key = replace(replace(secret_name, "/", "|"), replace(format("%s", prefix), "/", "|"), "")
        splitted_key = split("/", secret_name)
      }
    }
  ]...)

  secrets_map = {
    for key, value in local.secrets_map_pre : key => {
      secret_arn   = data.aws_secretsmanager_secret.secret[value.secret_name].id
      secret_name  = value.secret_name
      prefix       = value.prefix
      filtered_key = replace(replace((value.filtered_key != "" ? value.filtered_key : value.splitted_key[(length(value.splitted_key) - 1)]), "-", "_"), "/^[-_|]+/", "")
    }
  }

  secrets_plain = {
    for key, value in local.secrets_map : value.filtered_key => data.aws_secretsmanager_secret_version.secret[key].secret_string
    if !startswith(data.aws_secretsmanager_secret_version.secret[key].secret_string, "{")
  }

  secrets_json = merge([
    for key, secret in local.secrets_map : {
      for ent, value in tomap(jsondecode(data.aws_secretsmanager_secret_version.secret[key].secret_string)) :
      "${lower(secret.filtered_key)}_${lower(ent)}" => value
    }
    if startswith(data.aws_secretsmanager_secret_version.secret[key].secret_string, "{")
  ]...)

  all_secrets_map = merge(local.secrets_plain, local.secrets_json)
}

data "aws_secretsmanager_secret" "secret" {
  for_each = local.secrets_map_pre
  name     = each.value.secret_name
}

data "aws_secretsmanager_secret_version" "secret" {
  for_each  = local.secrets_map
  secret_id = each.value.secret_arn
}

resource "kubernetes_secret" "secrets" {
  count = length(local.secrets_path_filter) > 0 ? 1 : 0
  metadata {
    name      = "${var.release.name}-injected-secrets"
    namespace = var.namespace
  }
  data = local.all_secrets_map
}