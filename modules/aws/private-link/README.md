# StreamNative Cloud - Managed AWS Private Link

This Terraform module configures your AWS network to access private StreamNative BYOC pulsar service.

# QuickStart
Run the following terraform file with AWS Configuration:

```hcl
module "aws_private_link" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/private-link?ref=main"

  region       = "region"
  vpc_id       = "vpc-id"
  subnet_ids   = ["subnet-id"]
  service_name = "com.amazonaws.vpce.region.vpce-svc-name"
}
```

1. Run `terraform init`
2. Run `terraform plan`
3. Run `terraform apply`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The endpoint name | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region of vpc endpoint service. The VPC Endpoint must be the same region as Endpoint Service | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface. If unspecified, will auto-create one | `list(string)` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The vpc endpoint service name | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for the endpoint. Must be the same AZ as Endpoint Service. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the endpoint will be used | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_endpoint_arn"></a> [vpc\_endpoint\_arn](#output\_vpc\_endpoint\_arn) | n/a |
| <a name="output_vpc_endpoint_state"></a> [vpc\_endpoint\_state](#output\_vpc\_endpoint\_state) | n/a |
<!-- END_TF_DOCS -->