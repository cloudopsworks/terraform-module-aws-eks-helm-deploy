##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Only kubernetes_namespace_v1 supports moving state from the deprecated type in
# hashicorp/kubernetes 3.5.x. kubernetes_config_map and kubernetes_secret stay on the
# deprecated types until their *_v1 resources support state moves.
moved {
  from = kubernetes_namespace.this
  to   = kubernetes_namespace_v1.this
}
