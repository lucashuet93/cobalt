output "apim_service_id" {
  description = "The ID of the API Management Service created"
  value       = azurerm_api_management.apim_service.id
}

output "apim_gateway_url" {
  description = "The URL of the Gateway for the API Management Service"
  value       = azurerm_api_management.apim_service.gateway_url
}

output "apim_service_public_ip_addresses" {
  description = "The Public IP addresses of the API Management Service"
  value       = azurerm_api_management.apim_service.public_ip_addresses
}

output "apim_service_identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this API Management Service"
  value       = azurerm_api_management.apim_service.identity[0].tenant_id
}

output "apim_service_identity_object_id" {
  description = "The Principal ID for the Service Principal associated with the Managed Service Identity for the API Management Service"
  value       = azurerm_api_management.apim_service.identity[0].principal_id
}

output "apim_group_ids" {
  description = "The IDs of the API Management Groups created"
  value       = azurerm_api_management_group.group.*.id
}

output "apim_api_version_set_ids" {
  description = "The IDs of the API Version Sets created"
  value       = azurerm_api_management_api_version_set.api_version_set.*.id
}

output "apim_api_outputs" {
  description = "The IDs, state, and version outputs of the APIs created"
  value = [
    for api in azurerm_api_management_api.api :
    {
      id             = api.id
      is_current     = api.is_current
      is_online      = api.is_online
      version        = api.version
      version_set_id = api.version_set_id
    }
  ]
}

output "apim_product_ids" {
  description = "The IDs of the Products created"
  value       = azurerm_api_management_product.product.*.id
}

output "apim_named_value_ids" {
  description = "The IDs of the Named Values created"
  value       = azurerm_api_management_property.named_value.*.id
}

output "apim_backend_ids" {
  description = "The IDs of the Backends created"
  value       = azurerm_api_management_backend.backend.*.id
}

output "apim_product_api_ids" {
  description = "The IDs of the Product/API associations created"
  value       = azurerm_api_management_product_api.product_api.*.id
}

output "apim_product_group_ids" {
  description = "The IDs of the Product/Group associations created"
  value       = azurerm_api_management_product_group.product_group.*.id
}
