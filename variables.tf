variable "resource_group_name" {
  type    = string
  default = "iothub-rg"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "storage_account_name" {
  type    = string
  default = "tfstorage23456"
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "storage_container_name" {
  type    = string
  default = "example"
}

variable "container_access_type" {
  type    = string
  default = "private"
}

variable "base_name" {
  type    = string
  default = "dev"
}

variable "name" {
  type    = string
  default = "testiot"
}

variable "sku" {
  type = object(
    {
      name     = string
      capacity = number

    }
  )
  default = {

    name     = "S1"
    capacity = "1"
  }

}

variable "file_upload" {
  type = object({

    notifications      = bool
    max_delivery_count = number
    sas_ttl            = string
    lock_duration      = string
    default_ttl        = string
  })
  default = {
    notifications      = "true"
    max_delivery_count = 10
    sas_ttl            = "PT1H"
    lock_duration      = "PT1M"
    default_ttl        = "PT1H"
  }

}

variable "ip_filter_rule" {
  type = map(string)
  default = {
    name    = "ip"
    action  = "Accept"
    ip_mask = "10.0.0.0/31"
  }
}

variable "tags" {
  type = map(string)
  default = {
    purpose = "testing"
  }
}

variable "endpoint" {
  type = map(string)
  default = {
    name                       = "endpoint1"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    encoding                   = "Avro"

  }
}

variable "route" {
  type = map(string)
  default = {
    name      = "route1"
    source    = "DeviceMessages"
    condition = "true"
    enabled   = "true"
  }
}


variable "fallback_route" {
  type = object({
    condition = bool
    enabled   = bool
  })
  default = {
    condition = "true"
    enabled   = "true"
  }
}

variable "eventhub_endpoint_name" {
  type    = string
  default = "events"
}