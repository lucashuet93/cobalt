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
  tags                = var.tags
  policy {
    xml_content = var.apim_service_policy_xml_link == null ? var.apim_service_policy_xml_content : null
    xml_link    = var.apim_service_policy_xml_link
  }
  identity {
    type = "SystemAssigned"
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

resource "azurerm_api_management_api_version_set" "api_version_set" {
  count               = length(var.api_version_sets)
  name                = var.api_version_sets[count.index].name
  resource_group_name = data.azurerm_resource_group.apimsvcrg.name
  api_management_name = azurerm_api_management.apimservice.name
  display_name        = var.api_version_sets[count.index].display_name
  versioning_scheme   = var.api_version_sets[count.index].versioning_scheme
  description         = var.api_version_sets[count.index].description
  version_header_name = var.api_version_sets[count.index].version_header_name
  version_query_name  = var.api_version_sets[count.index].version_query_name
}

resource "azurerm_api_management_api" "api" {
  count               = length(var.apis)
  name                = var.apis[count.index].name
  resource_group_name = data.azurerm_resource_group.apimsvcrg.name
  api_management_name = azurerm_api_management.apimservice.name
  revision            = var.apis[count.index].revision
  display_name        = var.apis[count.index].display_name
  path                = var.apis[count.index].path
  protocols           = var.apis[count.index].protocols
  description         = var.apis[count.index].description
  version             = var.apis[count.index].version
  version_set_id      = var.apis[count.index].existing_version_set_id == null ? element(azurerm_api_management_api_version_set.api_version_set, var.apis[count.index].provisioned_version_set_index).id : var.apis[count.index].existing_version_set_id
  import {
    content_format = var.apis[count.index].file_format
    content_value  = var.apis[count.index].file_location
  }
}

resource "azurerm_api_management_product" "product" {
  count                 = length(var.products)
  product_id            = var.products[count.index].product_id
  resource_group_name   = data.azurerm_resource_group.apimsvcrg.name
  api_management_name   = azurerm_api_management.apimservice.name
  display_name          = var.products[count.index].display_name
  subscription_required = var.products[count.index].subscription_required
  approval_required     = var.products[count.index].approval_required
  published             = var.products[count.index].published
  description           = var.products[count.index].description
}

resource "azurerm_api_management_property" "named_value" {
  count               = length(var.named_values)
  name                = var.named_values[count.index].name
  resource_group_name = data.azurerm_resource_group.apimsvcrg.name
  api_management_name = azurerm_api_management.apimservice.name
  display_name        = var.named_values[count.index].display_name
  value               = var.named_values[count.index].value
  secret              = var.named_values[count.index].secret
  tags                = var.named_values[count.index].tags
}

resource "azurerm_api_management_backend" "backend" {
  count               = length(var.backends)
  name                = var.backends[count.index].name
  resource_group_name = data.azurerm_resource_group.apimsvcrg.name
  api_management_name = azurerm_api_management.apimservice.name
  protocol            = var.backends[count.index].protocol
  url                 = var.backends[count.index].url
  description         = var.backends[count.index].description
}
