# StreamNative Cloud - Managed Azure Private Endpoint

This Terraform modules configures your Azure network to access private StreamNative BYOC pulsar service.

## QuickStart
Run the following terraform file with Azure Configuration:

```hcl
provider "azurerm" {
  features {

  }
}

module "azure-managed-cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/private-endpoint?ref=main"

  name                       = "<the-private-endpoint-name>"
  resource_group_name        = "<the-resource-group-name>"
  vnet_name                  = "<the-vnet-name>"
  subnet_name                = "<the-subnet-name>"
  private_link_service_alias = "<the-private-link-service-alias>"
}

```

1. terraform init
2. terraform plan
3. terraform apply


## Set DNS

After create the Private Endpoint, you need to ask the manager of the Private Link Service to approve the request, and then
you can use module [private-dns](../private-dns) to create a private dns record for your pulsar cluster
