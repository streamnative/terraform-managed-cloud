<!--
  ~ Copyright 2023 StreamNative, Inc.
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License");
  ~ you may not use this file except in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~ See the License for the specific language governing permissions and
  ~ limitations under the License.
-->

# StreamNative Cloud - Managed Azure Vendor Access

This Terraform module creates Azure resource group and related managed identity within your Azure subscription. These resources give StreamNative access only for the provisioning and management of StreamNative's Managed Cloud offering.

For more information about StreamNative and our managed offerings for Apache Pulsar, visit our [website](https://streamnative.io/streamnativecloud/).

## Module Overview

This module creates the following resources:

- Azure Resource Group for management and access control (per subscription, can be shared across multiple clusters)
  - DNS zone
  - Managed Identity
  - Custom Role
- Azure Resource Group for StreamNative Managed Cloud resources (per Pulsar Cluster)
  - Access configuration for Managed Identity

## Usage

To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be [familiar](https://developer.hashicorp.com/terraform/tutorials/azure-get-started) with its usage for Azure. It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.



