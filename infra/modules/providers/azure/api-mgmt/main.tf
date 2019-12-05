data "azurerm_resource_group" "apimsvcrg" {
  name = var.service_plan_resource_group_name
}

resource "azurerm_api_management" "apimservice" {
  name                = var.apim_service_name
  location            = data.azurerm_resource_group.apimsvcrg.location
  resource_group_name = data.azurerm_resource_group.apimsvcrg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.apim_service_sku_tier}_${var.apim_service_sku_capacity}"
  policy {
    xml_content = var.apim_service_policy_xml_link == null ? var.apim_service_policy_xml_content : null
    xml_link    = var.apim_service_policy_xml_link
  }
}

resource "azurerm_api_management_group" "group" {
  count               = length(var.groups)
  name                = var.groups[count.index].name
  resource_group_name = data.azurerm_resource_group.apimsvcrg.name
  api_management_name = azurerm_api_management.apimservice.name
  display_name        = var.groups[count.index].display_name
  description         = var.groups[count.index].description
  external_id         = var.groups[count.index].external_id
  type                = var.groups[count.index].type
}
