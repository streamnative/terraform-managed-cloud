# StreamNative Cloud - Managed Azure Private DNS Record

This Terraform modules configures your Azure network to access private StreamNative BYOC pulsar service.

## QuickStart
Run the following terraform file with Azure Configuration:

```hcl
provider "azurerm" {
  features {

  }
}

module "azure-managed-cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/private-dns?ref=main"

  private_endpoint_name = "<the-private-endpoint-name>"
  resource_group_name   = "<the-resource-group-name>"
  vnet_name             = "<the-vnet-name>"
  domain                = "<the-domain-of-private-pulsar>"
}

```

1. terraform init
2. terraform plan
3. terraform apply
