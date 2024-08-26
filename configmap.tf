##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  config_path          = var.absolute_path == "" ? format("%s/%s", "values", var.release.name) : format("%s/%s/%s", var.absolute_path, "values", var.release.name)
  files_in_config_path = try(var.config_map.enabled, false) == true ? fileset(local.config_path, "*") : []
}

resource "kubernetes_config_map" "config_map" {
  count = try(var.config_map.enabled, false) == true && length(local.files_in_config_path) > 0 ? 1 : 0
  metadata {
    name      = "${var.release.name}-cm"
    namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
  }
  data = {
    for file in local.files_in_config_path : file => file("${local.config_path}/${file}")
  }
}
