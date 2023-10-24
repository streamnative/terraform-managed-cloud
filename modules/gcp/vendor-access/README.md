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

# StreamNative Cloud - GCP BYOC Vendor Access

This Terraform module creates IAM policies within your GCP project. These resources give StreamNative access only for the provisioning and management of StreamNative's BYOC offering.

For more information about StreamNative and our managed offerings for Apache Pulsar, visit our [website](https://streamnative.io/streamnativecloud/).

## Usage

To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be [familiar](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started) with its usage for GCP. It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.

### Get Started

Start by writing the following configuration to a new file `main.tf` containing the following Terraform code:

```hcl

provider "google" {
  project = "<YOUR_PROJECT>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/google/vendor-access?ref=v3.7.0"
  project = "<YOUR_PROJECT>"
}
```

After [authenticating to your GCP account](https://registry.terraform.io/providers/hashicorp/gcp/latest/docs#authentication-and-configuration) execute the following sequence of commands from the directory containing the `main.tf` configuration file:

1. `terraform init`
   <details><summary>(example output)</summary><p>

   ```bash
   $ terraform init

   Initializing modules...
   - sn_vendor in ../../../terraform-managed-cloud/modules/gcp/vendor-access

   Initializing the backend...

   Initializing provider plugins...
   - Finding hashicorp/google versions matching ">= 4.60.0"...
   - Installing hashicorp/google v5.3.0...
   - Installed hashicorp/google v5.3.0 (signed by HashiCorp)

   Terraform has created a lock file .terraform.lock.hcl to record the provider
   selections it made above. Include this file in your version control repository
   so that Terraform can guarantee to make the same selections by default when
   you run "terraform init" in the future.

   Terraform has been successfully initialized!

   You may now begin working with Terraform. Try running "terraform plan" to see
   any changes that are required for your infrastructure. All Terraform commands
   should now work.

   If you ever set or change modules or backend configuration for Terraform,
   rerun this command to reinitialize your working directory. If you forget, other
   commands will detect it and remind you to do so if necessary.
   ```

   </p></details>

2. `terraform plan`
   <details><summary>(example output)</summary><p>

   ```bash
   $ terraform plan

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
   following symbols:
   + create

   Terraform will perform the following actions:

   # module.sn_vendor.google_project_iam_member.sn_access["0"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/editor"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["1"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/editor"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["10"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.networkAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["11"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.networkAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["12"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/container.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["13"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/container.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["14"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/container.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["15"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/dns.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["16"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/dns.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["17"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/dns.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["18"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/storage.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["19"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/storage.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["2"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/editor"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["20"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/storage.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["21"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/iam.serviceAccountAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["22"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/iam.serviceAccountAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["23"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/iam.serviceAccountAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["24"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/iam.workloadIdentityPoolAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["25"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/iam.workloadIdentityPoolAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["26"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/iam.workloadIdentityPoolAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["27"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/resourcemanager.projectIamAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["28"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/resourcemanager.projectIamAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["29"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/resourcemanager.projectIamAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["3"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["4"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["5"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.admin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["6"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.loadBalancerAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["7"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:pool-automation@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.loadBalancerAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["8"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-support-general@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.loadBalancerAdmin"
       }

   # module.sn_vendor.google_project_iam_member.sn_access["9"] will be created
   + resource "google_project_iam_member" "sn_access" {
       + etag    = (known after apply)
       + id      = (known after apply)
       + member  = "serviceAccount:cloud-manager@sncloud-production.iam.gserviceaccount.com"
       + project = "<YOUR_PROJECT>"
       + role    = "roles/compute.networkAdmin"
       }

   # module.sn_vendor.google_project_service.gcp_apis[0] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "autoscaling.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[1] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "cloudresourcemanager.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[2] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "compute.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[3] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "container.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[4] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "dns.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[5] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "domains.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[6] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "iam.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[7] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "iamcredentials.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[8] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "networkmanagement.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[9] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "servicedirectory.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[10] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "servicemanagement.googleapis.com"
       }

   # module.sn_vendor.google_project_service.gcp_apis[11] will be created
   + resource "google_project_service" "gcp_apis" {
       + disable_on_destroy = false
       + id                 = (known after apply)
       + project            = "<YOUR_PROJECT>"
       + service            = "siteverification.googleapis.com"
       }

   Plan: 42 to add, 0 to change, 0 to destroy.

   ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

   Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run
   "terraform apply" now.
   ```

   </p></details>

3. `terraform apply`
   <details><summary>(example output)</summary><p>

   ```bash
   $ terraform apply

   Plan: 42 to add, 0 to change, 0 to destroy.

   Do you want to perform these actions?
   Terraform will perform the actions described above.
   Only 'yes' will be accepted to approve.

   Enter a value: yes

   module.sn_vendor.google_project_service.gcp_apis[2]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[6]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[5]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[9]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[4]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[11]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[10]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[8]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[1]: Creating...
   module.sn_vendor.google_project_service.gcp_apis[3]: Creating...
   ```

   </p></details>

## Terraform Docs
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.60.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.60.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [google_project_iam_member.sn_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.gcp_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extra_google_services"></a> [extra\_google\_services](#input\_extra\_google\_services) | Extra google API services need to be enabled. | `list(string)` | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | The project id of the target project | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | The role list will be associated with StreamNative GSA. | `list(string)` | <pre>[<br>  "roles/editor",<br>  "roles/compute.admin",<br>  "roles/compute.loadBalancerAdmin",<br>  "roles/compute.networkAdmin",<br>  "roles/container.admin",<br>  "roles/dns.admin",<br>  "roles/storage.admin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/iam.workloadIdentityPoolAdmin",<br>  "roles/resourcemanager.projectIamAdmin"<br>]</pre> | no |
| <a name="input_streamnative_support_access_gsa"></a> [streamnative\_support\_access\_gsa](#input\_streamnative\_support\_access\_gsa) | The GSA will be used by StreamnNative support team. | `list(string)` | <pre>[<br>  "cloud-support-general@sncloud-production.iam.gserviceaccount.com"<br>]</pre> | no |
| <a name="input_streamnative_vendor_access_gsa"></a> [streamnative\_vendor\_access\_gsa](#input\_streamnative\_vendor\_access\_gsa) | The GSA will be used by StreamnNative cloud. | `list(string)` | <pre>[<br>  "cloud-manager@sncloud-production.iam.gserviceaccount.com",<br>  "pool-automation@sncloud-production.iam.gserviceaccount.com"<br>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_google_services"></a> [google\_services](#output\_google\_services) | Enabled google services. |
| <a name="output_iam_bindings"></a> [iam\_bindings](#output\_iam\_bindings) | Configured iam policies. |
