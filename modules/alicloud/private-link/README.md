# StreamNative Cloud - Managed AliCloud Private Link

This Terraform module configures your AliCloud network to access private StreamNative BYOC pulsar service.

# QuickStart

Run the following terraform file with [AliCloud credentials](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs#authentication) configured in your environment:

## Create PrivateLink with default settings

```hcl
provider "alicloud" {
  region = "region"
}

module "alicloud_private_link" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/alicloud/private-link?ref=main"

  privatelink_service_id = "<privatelink_service_id>"
  domain_name = "<pulsar_domain_suffix>"
  endpoint_name = "streamnative-pulsar-endpoint"

  vpc_id = "<vpc_id>"
  vswitches = [
    {
        id = "<vswitch_id>"
        zone = "<zone_id>"
    },
    {
        id = "<vswitch_id2>"
        zone = "<zone_id2>"
    }
  ]
}
```

## Create PrivateLink with customized Security Group

```hcl
provider "alicloud" {
  region = "region"
}

module "alicloud_private_link" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/alicloud/private-link?ref=main"

  privatelink_service_id = "<privatelink_service_id>"
  domain_name = "<pulsar_domain_suffix>"
  endpoint_name = "streamnative-pulsar-endpoint"

  vpc_id = "<vpc_id>"
  vswitches = [
    {
        id = "<vswitch_id>"
        zone = "<zone_id>"
    },
    {
        id = "<vswitch_id2>"
        zone = "<zone_id2>"
    }
  ]
  security_group_ids = ["<security_group_id>"]
}
```

Make sure you have the following inbound rules in your security group:

- Allow TCP port 443 from the VPC
- Allow TCP port 6651 from the VPC
- Allow TCP port 9093 from the VPC
- Allow TCP port 5671 from the VPC
- Allow TCP port 8883 from the VPC

## Run terraform

1. Run `terraform init`
2. Run `terraform plan`
3. Run `terraform apply`

# Terraform Docs

## Requirements

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="requirement_alicloud"></a> [alicloud](#requirement_alicloud) | 1.248.0 |

## Providers

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="provider_alicloud"></a> [alicloud](#provider_alicloud) | 1.248.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                           | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [alicloud_privatelink_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/privatelink_vpc_endpoint)           | resource |
| [alicloud_privatelink_vpc_endpoint_zone.this](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/privatelink_vpc_endpoint_zone) | resource |
| [alicloud_pvtz_zone.this](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/pvtz_zone)                                         | resource |
| [alicloud_pvtz_zone_attachment.this](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/pvtz_zone_attachment)                   | resource |
| [alicloud_pvtz_zone_record.this](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/pvtz_zone_record)                           | resource |
| [alicloud_security_group.new](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/security_group)                                | resource |
| [alicloud_security_group_rule.new](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/security_group_rule)                      | resource |

## Inputs

| Name                                                                                                                  | Description                                                                                                       | Type                                                                        | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Required |
| --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name)                                                    | The domain suffix of the Pulsar endpoint, it should be obtained from StreamNative Cloud.                          | `string`                                                                    | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |   yes    |
| <a name="input_endpoint_name"></a> [endpoint_name](#input_endpoint_name)                                              | The name of the VPC endpoint will be created, used to identify from other endpoints.                              | `string`                                                                    | `"streamnative-pulsar-endpoint"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |    no    |
| <a name="input_privatelink_service_id"></a> [privatelink_service_id](#input_privatelink_service_id)                   | The ID of the PrivateLink service, it should be obtained from StreamNative Cloud.                                 | `string`                                                                    | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |   yes    |
| <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids)                               | The list of security group IDs to associate with the endpoint, will create a new security group if this is empty. | `list(string)`                                                              | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_security_group_inbound_rules"></a> [security_group_inbound_rules](#input_security_group_inbound_rules) | List of inbound rules for the security group, allowing traffic to the endpoint.                                   | <pre>list(object({<br> port = string<br> description = string<br> }))</pre> | <pre>[<br> {<br> "description": "Allow HTTPS traffic to the endpoint",<br> "port": "443/443"<br> },<br> {<br> "description": "Allow Pulsar traffic to the endpoint",<br> "port": "6651/6651"<br> },<br> {<br> "description": "Allow Kafka traffic to the endpoint",<br> "port": "9093/9093"<br> },<br> {<br> "description": "Allow AMQP traffic to the endpoint",<br> "port": "5671/5671"<br> },<br> {<br> "description": "Allow MQTT traffic to the endpoint",<br> "port": "8883/8883"<br> }<br>]</pre> |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                   | The ID of the VPC to create the endpoint in.                                                                      | `string`                                                                    | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |   yes    |
| <a name="input_vswitches"></a> [vswitches](#input_vswitches)                                                          | The list of VSwitches to associate with the endpoint.                                                             | <pre>list(object({<br> id = string<br> zone = string<br> }))</pre>          | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |   yes    |

## Outputs

No outputs.
