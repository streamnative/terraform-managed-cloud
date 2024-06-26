# Copyright 2023 StreamNative, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "azurerm_subscription" "current" {
}

locals {
  tags = merge({
    "Vendor"                 = "StreamNative"
    "Service"                = "StreamNative Cloud"
  }, var.additional_tags)

  split_domain = split(".", var.domain)
  domain_name = local.split_domain[0]
  root_domain = join(".", slice(local.split_domain, 1, length(local.split_domain)))
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_private_endpoint" "pe" {
  name                = var.name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                              = "streamnative-privateserviceconnection"
    private_connection_resource_alias = var.private_link_service_alias
    is_manual_connection              = true
    request_message                   = "streamnative-pl"
  }

  tags = local.tags
}

resource "azurerm_private_dns_zone" "private-zone" {
  name                = local.root_domain
  resource_group_name = var.resource_group_name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-link" {
  name                  = "private-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private-zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_a_record" "pulsar-record" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.private-zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address]
}
