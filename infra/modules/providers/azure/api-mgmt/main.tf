data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  product_api_associations = flatten([
    for product in var.products : [
      for api_name in product.apis : [
        format("%s = %s", product.product_id, api_name)
      ]
    ]
  ])
  product_group_associations = flatten([
    for product in var.products : [
      for group_name in product.groups : [
        format("%s = %s", product.product_id, group_name)
      ]
    ]
  ])
  product_tag_associations = flatten([
    for product in var.products : [
      for tag_name in product.tags : [
        format("%s = %s", product.product_id, tag_name)
      ]
    ]
  ])
  product_policy_associations = [
    for product in var.products :
    format("%s = %s = %s", product.product_id, product.policy.content, product.policy.format)
    if product.policy != null
  ]
  api_tag_associations = flatten([
    for api in var.apis : [
      for tag_name in api.tags : [
        format("%s = %s", api.name, tag_name)
      ]
    ]
  ])
  api_policy_associations = [
    for api in var.apis :
    format("%s = %s = %s", api.name, api.policy.content, api.policy.format)
    if api.policy != null
  ]
  operation_policy_associations = flatten([
    for api in var.apis : [
      for operation_policy in api.operation_policies : [
        format("%s = %s = %s = %s", api.name, operation_policy.operation_id, operation_policy.content, operation_policy.format)
      ]
    ]
  ])
  service_policy_is_url = replace(var.policy.format, "link", "") != var.policy.format
}

resource "azurerm_api_management" "apim_service" {
  name                = var.apim_service_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.sku_tier}_${var.sku_capacity}"
  tags                = var.tags
  policy {
    xml_content = local.service_policy_is_url == false ? var.policy.content : null
    xml_link    = local.service_policy_is_url == true ? var.policy.content : null
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_property" "named_value" {
  count               = length(var.named_values)
  name                = var.named_values[count.index].name
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim_service.name
  display_name        = var.named_values[count.index].display_name
  value               = var.named_values[count.index].value
  secret              = var.named_values[count.index].secret
  tags                = var.named_values[count.index].tags
}

resource "azurerm_api_management_group" "group" {
  count               = length(var.groups)
  name                = var.groups[count.index].name
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim_service.name
  display_name        = var.groups[count.index].display_name
  description         = var.groups[count.index].description
  external_id         = var.groups[count.index].external_id
  type                = var.groups[count.index].type
  depends_on          = [azurerm_api_management_property.named_value]
}

resource "azurerm_api_management_api_version_set" "api_version_set" {
  count               = length(var.api_version_sets)
  name                = var.api_version_sets[count.index].name
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim_service.name
  display_name        = var.api_version_sets[count.index].display_name
  versioning_scheme   = var.api_version_sets[count.index].versioning_scheme
  description         = var.api_version_sets[count.index].description
  version_header_name = var.api_version_sets[count.index].version_header_name
  version_query_name  = var.api_version_sets[count.index].version_query_name
  depends_on          = [azurerm_api_management_property.named_value]
}

resource "azurerm_api_management_api" "api" {
  count               = length(var.apis)
  name                = var.apis[count.index].name
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim_service.name
  revision            = var.apis[count.index].revision
  display_name        = var.apis[count.index].display_name
  path                = var.apis[count.index].path
  protocols           = var.apis[count.index].protocols
  description         = var.apis[count.index].description
  version             = var.apis[count.index].version
  version_set_id      = var.apis[count.index].existing_version_set_id == null ? (var.apis[count.index].provisioned_version_set_index == null ? null : element(azurerm_api_management_api_version_set.api_version_set, var.apis[count.index].provisioned_version_set_index).id) : var.apis[count.index].existing_version_set_id
  import {
    content_format = var.apis[count.index].api_import_file.format
    content_value  = var.apis[count.index].api_import_file.content
  }
  depends_on = [azurerm_api_management_property.named_value, azurerm_api_management_api_version_set.api_version_set]
}

resource "azurerm_api_management_product" "product" {
  count                 = length(var.products)
  product_id            = var.products[count.index].product_id
  resource_group_name   = data.azurerm_resource_group.rg.name
  api_management_name   = azurerm_api_management.apim_service.name
  display_name          = var.products[count.index].display_name
  subscription_required = var.products[count.index].subscription_required
  approval_required     = var.products[count.index].approval_required
  published             = var.products[count.index].published
  description           = var.products[count.index].description
  depends_on            = [azurerm_api_management_property.named_value]
}

resource "azurerm_api_management_backend" "backend" {
  count               = length(var.backends)
  name                = var.backends[count.index].name
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim_service.name
  protocol            = var.backends[count.index].protocol
  url                 = var.backends[count.index].url
  description         = var.backends[count.index].description
  depends_on          = [azurerm_api_management_property.named_value]
}

resource "azurerm_api_management_product_api" "product_api" {
  count               = length(local.product_api_associations)
  product_id          = split(" = ", local.product_api_associations[count.index])[0]
  api_name            = split(" = ", local.product_api_associations[count.index])[1]
  api_management_name = azurerm_api_management.apim_service.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_api_management_product.product, azurerm_api_management_api.api]
}


resource "azurerm_api_management_product_group" "product_group" {
  count               = length(local.product_group_associations)
  product_id          = split(" = ", local.product_group_associations[count.index])[0]
  group_name          = split(" = ", local.product_group_associations[count.index])[1]
  api_management_name = azurerm_api_management.apim_service.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_api_management_product.product, azurerm_api_management_group.group]
}

resource "azurerm_template_deployment" "service_tag" {
  name                = "service_tag"
  count               = length(var.available_tags)
  resource_group_name = data.azurerm_resource_group.rg.name

  parameters = {
    service_name     = var.apim_service_name
    tag_name         = var.available_tags[count.index].name
    tag_display_name = var.available_tags[count.index].display_name
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/arm-templates/service-tags.template.json")
  depends_on      = [azurerm_api_management.apim_service]
}

resource "azurerm_template_deployment" "api_tag" {
  name                = "api_tag"
  count               = length(local.api_tag_associations)
  resource_group_name = data.azurerm_resource_group.rg.name

  parameters = {
    service_name = var.apim_service_name
    api_name     = split(" = ", local.api_tag_associations[count.index])[0]
    tag_name     = split(" = ", local.api_tag_associations[count.index])[1]
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/arm-templates/api-tags.template.json")
  depends_on      = [azurerm_api_management_api.api, azurerm_template_deployment.service_tag]
}

resource "azurerm_template_deployment" "product_tag" {
  name                = "product_tag"
  count               = length(local.product_tag_associations)
  resource_group_name = data.azurerm_resource_group.rg.name

  parameters = {
    service_name = var.apim_service_name
    product_id   = split(" = ", local.product_tag_associations[count.index])[0]
    tag_name     = split(" = ", local.product_tag_associations[count.index])[1]
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/arm-templates/product-tags.template.json")
  depends_on      = [azurerm_api_management_product.product, azurerm_template_deployment.service_tag]
}

resource "azurerm_template_deployment" "api_policy" {
  name                = "api_policy"
  count               = length(local.api_policy_associations)
  resource_group_name = data.azurerm_resource_group.rg.name

  parameters = {
    service_name   = var.apim_service_name
    api_name       = split(" = ", local.api_policy_associations[count.index])[0]
    policy_content = split(" = ", local.api_policy_associations[count.index])[1]
    policy_format  = split(" = ", local.api_policy_associations[count.index])[2]
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/arm-templates/api-policy.template.json")
  depends_on      = [azurerm_api_management_api.api]
}

resource "azurerm_template_deployment" "product_policy" {
  name                = "product_policy"
  count               = length(local.product_policy_associations)
  resource_group_name = data.azurerm_resource_group.rg.name

  parameters = {
    service_name   = var.apim_service_name
    product_id     = split(" = ", local.product_policy_associations[count.index])[0]
    policy_content = split(" = ", local.product_policy_associations[count.index])[1]
    policy_format  = split(" = ", local.product_policy_associations[count.index])[2]
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/arm-templates/product-policy.template.json")
  depends_on      = [azurerm_api_management_product.product]
}

resource "azurerm_template_deployment" "operation_policy" {
  name                = "operation_policy"
  count               = length(local.operation_policy_associations)
  resource_group_name = data.azurerm_resource_group.rg.name

  parameters = {
    service_name   = var.apim_service_name
    api_name       = split(" = ", local.operation_policy_associations[count.index])[0]
    operation_id   = split(" = ", local.operation_policy_associations[count.index])[1]
    policy_content = split(" = ", local.operation_policy_associations[count.index])[2]
    policy_format  = split(" = ", local.operation_policy_associations[count.index])[3]
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/arm-templates/operation-policy.template.json")
  depends_on      = [azurerm_api_management_api.api]
}
