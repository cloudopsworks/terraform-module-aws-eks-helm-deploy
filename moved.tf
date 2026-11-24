##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

moved {
  from = kubernetes_config_map.config_map
  to   = kubernetes_config_map_v1.config_map
}

moved {
  from = kubernetes_namespace.this
  to   = kubernetes_namespace_v1.this
}

moved {
  from = kubernetes_secret.secret_files
  to   = kubernetes_secret_v1.secret_files
}

moved {
  from = kubernetes_secret.secrets
  to   = kubernetes_secret_v1.secrets
}

