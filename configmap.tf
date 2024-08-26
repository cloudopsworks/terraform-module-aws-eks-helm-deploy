##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  config_path          = var.absolute_path == "" ? format("%s/%s", "values", var.release.name) : format("%s/%s/%s", var.absolute_path, "values", var.release.name)
  files_in_config_path = try(var.config_map.enabled, false) == true ? fileset(local.config_path, "*") : []
  mount_overrides = try(var.config_map.mount_point, "") != "" ? {
    "injectedVolumes[0].name"           = "${var.release.name}-injected-cm"
    "injectedVolumes[0].configMap.name" = "${var.release.name}-injected-cm"
    "injectedVolumeMounts[0].name"      = "${var.release.name}-injected-cm"
    "injectedVolumeMounts[0].mountPath" = var.config_map.mount_point
  } : {}
}

resource "kubernetes_config_map" "config_map" {
  count = try(var.config_map.enabled, false) == true && length(local.files_in_config_path) > 0 ? 1 : 0
  metadata {
    name      = "${var.release.name}-injected-cm"
    namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
    labels = {
      "app.kubernetes.io/name"       = var.release.name
      "app.kubernetes.io/version"    = var.release.version
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  data = {
    for file in local.files_in_config_path : file => file("${local.config_path}/${file}")
  }
}
