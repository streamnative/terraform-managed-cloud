# DNS Zone Module

To create a new zone in the target project and then create the delegations in the source project.

## Quickstart

```hcl
module "gcp-dns-zone" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/dns-zone"

  source_project = "<input-project-holds-source-zone>"
  target_project = "<input-project-holds-target-zone>"

  source_zone_name     = "<input-source-zone>"
  target_zone_name     = "<input-target-zone>"
  target_zone_dns_name = "<input-target-dns>"
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google.source"></a> [google.source](#provider\_google.source) | n/a |
| <a name="provider_google.target"></a> [google.target](#provider\_google.target) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_dns_managed_zone.target](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.delegate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_managed_zone.source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_source_project"></a> [source\_project](#input\_source\_project) | The gcp project which holds the parent zone | `string` | n/a | yes |
| <a name="input_source_zone_name"></a> [source\_zone\_name](#input\_source\_zone\_name) | The parent zone in which create the delegation records | `string` | n/a | yes |
| <a name="input_target_project"></a> [target\_project](#input\_target\_project) | The gcp project which holds the new zone | `string` | n/a | yes |
| <a name="input_target_zone_dns_name"></a> [target\_zone\_dns\_name](#input\_target\_zone\_dns\_name) | The new DNS name | `string` | n/a | yes |
| <a name="input_target_zone_name"></a> [target\_zone\_name](#input\_target\_zone\_name) | The new zone name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->