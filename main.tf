terraform {
  backend "azure" {}
  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.resource_group_location
}

resource "azurerm_virtual_network" "example" {
  name                = "cdcpoc-vnet"
  address_space       = ["10.7.29.0/29"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_storage_account" "rgname" {
  name                     = "cdcbckginfrastorageacc"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access  = true

}
resource "azurerm_storage_container" "rgname" {
  name                  = "cdccontainer"
  storage_account_name  = azurerm_storage_account.rgname.name
  container_access_type = "container"
}

resource "azurerm_sql_server" "rgname" {
  name                         = "cdcpocsqlsvr1"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  version                      = "12.0"
  administrator_login          = "CDC-Admin"
  administrator_login_password = "4-v3ry-53cr37-P455w0rd"
}

resource "azurerm_sql_database" "rgname" {
  name                             = "cdcdb"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  server_name                      = azurerm_sql_server.rgname.name
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"
}

resource "azurerm_sql_firewall_rule" "rgname" {
  name                = "allow-azure-services1"
  resource_group_name      = var.resource_group_name
  server_name         = azurerm_sql_server.rgname.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_app_service_plan" "example" {
  name                = var.azurerm_app_service_plan_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
resource "azurerm_app_service" "example" {
  name                = "producerapi"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id  
  site_config {
    java_version = "1.8"
    linux_fx_version = "JAVA|8-jre8"
  }
}



resource "azurerm_app_service" "consumerapi" {
  name                = "cdcconsumerapi"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id  
  site_config {
    java_version = "1.8"
    linux_fx_version = "JAVA|8-jre8"
  }
}
resource "azurerm_eventhub_namespace" "rgname" {
  name                = "cdcehnamespace1"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 2

  tags = {
    environment = "CDC-PoC"
  }
}
resource "azurerm_eventhub_namespace_authorization_rule" "rgname" {
  name                = "cdcnsauthrule1"
  namespace_name      = azurerm_eventhub_namespace.rgname.name
  resource_group_name = var.resource_group_name

  listen = true
  send   = true
  manage = false
}

resource "azurerm_eventhub" "rgname" {
  name                = "cdceh1"
  namespace_name      = azurerm_eventhub_namespace.rgname.name
  resource_group_name = var.resource_group_name

  partition_count   = 2
  message_retention = 5
}

resource "azurerm_eventhub_authorization_rule" "rgname" {
  name                = "cdcehnauthrule1"
  namespace_name      = azurerm_eventhub_namespace.rgname.name
  eventhub_name       = azurerm_eventhub.rgname.name
  resource_group_name = var.resource_group_name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_eventhub_consumer_group" "rgname" {
  name                = "cdcehcg1"
  namespace_name      = azurerm_eventhub_namespace.rgname.name
  eventhub_name       = azurerm_eventhub.rgname.name
  resource_group_name = var.resource_group_name
  user_metadata       = "cdcpoc"
}

resource "azurerm_key_vault" "example" {
  name                = "cdcdemokv"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  tenant_id           = "4adae17a-ae8f-4ebe-b9b9-730105aa1002"
  sku_name            = "premium"

  purge_protection_enabled = true

  access_policy {
    tenant_id = "4adae17a-ae8f-4ebe-b9b9-730105aa1002"
    object_id = "82fef68d-861f-42a8-80e6-3ae6fbac2e65"

    key_permissions = [
      "list",
      "create",
      "delete",
      "get",
      "update",
    ]

  }

  access_policy {
    tenant_id = "4adae17a-ae8f-4ebe-b9b9-730105aa1002"
    object_id = "82fef68d-861f-42a8-80e6-3ae6fbac2e65"

    key_permissions = [
      "get",
      "unwrapKey",
      "wrapKey",
    ]
  }
}

resource "azurerm_key_vault_key" "example" {
  name         = "cdcdemokey"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 3072

  key_opts = [
    "decrypt",
    "encrypt",
    "wrapKey",
    "unwrapKey",
  ]
}

resource "azurerm_cosmosdb_account" "example" {
  name                = "cdcdemo-cosmosdb"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"
  key_vault_key_id    = azurerm_key_vault_key.example.versionless_id

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    prefix            = "cdcdemo-customid"
    location          = var.resource_group_location
    failover_priority = 0
  }
}
