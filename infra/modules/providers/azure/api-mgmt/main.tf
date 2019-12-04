resource "azurerm_resource_group" "example" {
  name     = "lucas-terraform"
  location = "East US"
}

resource "azurerm_api_management" "example" {
  name                = "lucas-terraform-apim"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  publisher_name      = "Microsoft"
  publisher_email     = "lucashh@microsoft.com"
  sku_name = "Developer_1"

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML
  }
}