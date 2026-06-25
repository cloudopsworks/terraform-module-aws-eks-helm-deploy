##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# is_hub: false # (Optional) Indicates whether this deployment belongs to a hub configuration. Default: false.
variable "is_hub" {
  description = "Indicates whether this deployment belongs to a hub configuration."
  type        = bool
  default     = false
}

# spoke_def: "001" # (Optional) Three-digit spoke identifier used in generated names. Default: "001".
variable "spoke_def" {
  description = "Three-digit spoke identifier used in generated names."
  type        = string
  default     = "001"
  validation {
    condition     = (length(var.spoke_def) == 3) && tonumber(var.spoke_def) != null
    error_message = "The spoke_def must be a 3 digit number as string."
  }
}

# org: # (Required) Organization context used by naming and tagging.
#   organization_name: "Example Organization" # (Required) Full organization name.
#   organization_unit: "platform"             # (Required) Organization unit or team name used in resource names.
#   environment_type: "prod"                  # (Required) Environment type such as dev, stage, prod, or shared.
#   environment_name: "primary"               # (Required) Environment name used in resource names and tags.
variable "org" {
  description = "Organization context used by naming and tagging."
  type = object({
    organization_name = string
    organization_unit = string
    environment_type  = string
    environment_name  = string
  })
}

# extra_tags: {} # (Optional) Additional tags merged with generated Cloud Ops Works common tags. Default: {}.
#   CostCenter: "platform"
variable "extra_tags" {
  description = "Additional tags merged with generated Cloud Ops Works common tags."
  type        = map(string)
  default     = {}
}
