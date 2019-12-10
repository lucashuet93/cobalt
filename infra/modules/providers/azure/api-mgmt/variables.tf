variable "service_plan_resource_group_name" {
  description = "The name of the resource group in which the service plan was created."
  type        = string
}

variable "apim_service_name" {
  description = "The name of the apim service"
  type        = string
}

variable "apim_service_sku_tier" {
  description = "Apim service sku tier"
  type        = string
}

variable "apim_service_sku_capacity" {
  description = "The number of deployed units of the sku, which must be a positive integer"
  type        = number
}

variable "publisher_name" {
  description = "The name of publisher/company"
  type        = string
}

variable "publisher_email" {
  description = "The email of publisher/company"
  type        = string
}

variable "apim_service_policy_xml_content" {
  description = "Service policy xml"
  type        = string
  default     = <<XML
<policies>
    <inbound />
    <backend />
    <outbound />
    <on-error />
</policies>
XML
}

variable "apim_service_policy_xml_link" {
  description = "Service policy xml"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "groups" {
  type = list(object({
    name         = string
    display_name = string
    description  = string
    external_id  = string
    type         = string
  }))
  default = []
}

variable "api_version_sets" {
  type = list(object({
    name                = string
    display_name        = string
    versioning_scheme   = string
    description         = string
    version_header_name = string
    version_query_name  = string
  }))
  default = []
}

variable "apis" {
  type = list(object({
    name                          = string
    display_name                  = string
    revision                      = string
    path                          = string
    protocols                     = list(string)
    description                   = string
    file_format                   = string
    file_location                 = string
    version                       = string
    existing_version_set_id       = string
    provisioned_version_set_index = number
  }))
  default = []
}

variable "products" {
  type = list(object({
    product_id            = string
    display_name          = string
    subscription_required = bool
    approval_required     = bool
    published             = bool
    description           = string
    apis                  = list(string)
    groups                = list(string)
  }))
  default = []
}

variable "named_values" {
  type = list(object({
    name         = string
    display_name = string
    value        = string
    secret       = bool
    tags         = list(string)
  }))
  default = []
}

variable "backends" {
  type = list(object({
    name        = string
    protocol    = string
    url         = string
    description = string
  }))
  default = []
}
