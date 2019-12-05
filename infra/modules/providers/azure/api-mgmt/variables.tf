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

variable "apim_service_policy_xml_content" {
  description = "Service policy xml"
  type        = string
  default     = null
}

variable "apim_service_policy_xml_link" {
  description = "Service policy xml"
  type        = string
  default     = null
}

variable "publisher_name" {
  description = "The name of publisher/company"
  type        = string
}

variable "publisher_email" {
  description = "The email of publisher/company"
  type        = string
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

