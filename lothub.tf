provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type
}

resource "azurerm_iothub" "iothub" {
  name                = "${var.base_name}-iot-${var.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = var.sku.name
    capacity = var.sku.capacity
  }

  file_upload {
    connection_string  = azurerm_storage_account.storage_account.primary_blob_connection_string
    container_name     = azurerm_storage_container.container.name
    notifications      = var.file_upload.notifications
    max_delivery_count = var.file_upload.max_delivery_count
    sas_ttl            = var.file_upload.sas_ttl
    lock_duration      = var.file_upload.lock_duration
    default_ttl        = var.file_upload.default_ttl
  }

  public_network_access_enabled = "true"

  ip_filter_rule {
    name    = var.ip_filter_rule.name
    action  = var.ip_filter_rule.action
    ip_mask = var.ip_filter_rule.ip_mask
  }

  tags = var.tags

}

resource "azurerm_iothub_endpoint_storage_container" "endpoint" {
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iothub.name
  name                = var.endpoint.name

  connection_string          = azurerm_storage_account.storage_account.primary_blob_connection_string
  batch_frequency_in_seconds = var.endpoint.batch_frequency_in_seconds
  max_chunk_size_in_bytes    = var.endpoint.max_chunk_size_in_bytes
  container_name             = azurerm_storage_container.container.name
  encoding                   = var.endpoint.encoding
  file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"

}

resource "azurerm_iothub_route" "route" {
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iothub.name
  name                = var.route.name
  source              = var.route.source
  condition           = var.route.condition
  endpoint_names      = [azurerm_iothub_endpoint_storage_container.endpoint.name]
  enabled             = var.route.enabled
}

resource "azurerm_iothub_fallback_route" "fallback_route" {
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iothub.name
  condition           = var.fallback_route.condition
  endpoint_names      = [azurerm_iothub_endpoint_storage_container.endpoint.name]
  enabled             = var.fallback_route.enabled
}

resource "azurerm_iothub_consumer_group" "consumer_group" {
  name                   = "${var.base_name}-ihc-${var.name}"
  iothub_name            = azurerm_iothub.iothub.name
  eventhub_endpoint_name = var.eventhub_endpoint_name
  resource_group_name    = azurerm_resource_group.rg.name
}