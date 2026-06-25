locals {
  local_vars  = yamldecode(file("./inputs.yaml"))
  spoke_vars  = yamldecode(file(find_in_parent_folders("spoke-inputs.yaml")))
  region_vars = yamldecode(file(find_in_parent_folders("region-inputs.yaml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-inputs.yaml")))
  global_vars = yamldecode(file(find_in_parent_folders("global-inputs.yaml")))

  local_tags  = jsondecode(file("./local-tags.json"))
  spoke_tags  = jsondecode(file(find_in_parent_folders("spoke-tags.json")))
  region_tags = jsondecode(file(find_in_parent_folders("region-tags.json")))
  env_tags    = jsondecode(file(find_in_parent_folders("env-tags.json")))
  global_tags = jsondecode(file(find_in_parent_folders("global-tags.json")))

  tags = merge(
    local.global_tags,
    local.env_tags,
    local.region_tags,
    local.spoke_tags,
    local.local_tags
  )
}

include "root" {
  path = find_in_parent_folders("{{ .RootFileName }}")
}

dependency "eks" {
  config_path = "{{ .eks_dependency_path }}"
  #skip_outputs = true
  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "destroy"]
  mock_outputs = {
    cluster_name = "eks-cluster"
    lb_irsa_role = {
      arn  = "arn:aws:iam::123456789012:role/eks-lb-irsa-role"
      name = "eks-lb-irsa-role"
    }
  }
}

generate "kubernetes_provider" {
  path      = "provider.l.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "cluster" {
  name = "${dependency.eks.outputs.cluster_name}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${dependency.eks.outputs.cluster_name}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
EOF
}

terraform {
  source = "{{ .sourceUrl }}"
}

inputs = {
  is_hub     = {{ .is_hub }}
  org        = local.env_vars.org
  spoke_def  = local.spoke_vars.spoke_def
  {{- range .requiredVariables }}
  {{- if ne .Name "org" }}
  {{ .Name }} = local.local_vars.{{ .Name }}
  {{- end }}
  {{- end }}
  {{- range .optionalVariables }}
  {{- if not (eq .Name "extra_tags" "is_hub" "spoke_def" "org") }}
  {{ .Name }} = try(local.local_vars.{{ .Name }}, {{ .DefaultValue }})
  {{- end }}
  {{- end }}
  extra_tags = local.tags
}