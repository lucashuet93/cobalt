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