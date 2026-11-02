<!--
  ~ Copyright 2026 StreamNative, Inc.
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

# Azure vendor access onboarding preview

Install this module in a fresh subscription namespace to verify the Azure onboarding proposed in SNIP-187. Use a separate root module and state with Terraform 1.11+ and the pinned AzureRM 5.11.0 provider. The existing `sn-cloud-manager` and `vendor-access` modules use a different provider major and own overlapping resource names. Migration of an existing installation requires a separate ownership plan.

```hcl
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

module "onboarding" {
  source            = "./modules/azure/vendor-access-onboarding" # from repository root
  organization_name = "o-example"
}

output "discovery_hint" {
  value = module.onboarding.discovery_hint
}
```

Select the intended Azure CLI subscription before planning. Set `ARM_SUBSCRIPTION_ID` from `az account show --query id --output tsv` when the provider requires it. The only required module input is the canonical StreamNative organization name. This installer needs Python 3.10+, Azure CLI and access to create the manager resource group, identities, federated credentials, custom role and scoped assignments. The first apply checks that the manager name and reserved workload prefix are unused. That check cannot exclude concurrent Azure writes.

The default installation creates two named managed identities. The trust subjects follow the pinned `sn-cloud-manager` configuration with the organization-specific Google token audience. Automation can read the two identities and their federated credentials at their exact resource scopes. The module outputs `discovery_hint` with `organization`, `subscriptionId`, `tenantId` and `automationClientId`. Set the optional `discovery_endpoint` to a reviewed receiver to publish these fields on apply. The publisher accepts HTTPS or local HTTP for testing, rejects redirects and sends no Azure or StreamNative credentials. HTTP 202 means that the receiver accepted the hint. A controller still needs to verify the trusted pending CloudConnection and live Azure identities.

## Verify two CEs

Set `environment = "test"` and configure up to two fresh `verification_targets` before installing the experiment. The map keys are canonical CE UIDs. The synthetic keys `ce1` and `ce2` are also accepted to replay the published Azure experiment. For its exact names, use `organization_name = "o-snip187-2nov-a"` with these additional module arguments.

```hcl
environment = "test"
verification_targets = {
  ce1 = { location = "eastus", aks_name = "sn187-aks-ce1", node_resource_group = "sn187-2nov-a-nodes-ce1" }
  ce2 = { location = "eastus", aks_name = "sn187-aks-ce2", node_resource_group = "sn187-2nov-a-nodes-ce2" }
}
enable_node_reader_verification = true
```

Each workload ID uses `snce-<first 12 hex digits of sha256(org + "/" + environment)>-<location>-<CE UID>`. The installer creates each fresh workload group using the `workload_contract` output tags plus `sn-ce=<CE UID>`. Three policies assign Contributor and Azure Kubernetes Service Cluster Admin Role to automation, and Azure Kubernetes Service Cluster User Role to support. Each policy matches only the configured group IDs with the correct namespace and tags. The optional two node policies additionally require the correct AKS ID and its paired actual node group.

The verification targets enable a subscription-scoped custom role for each policy identity with deployment permissions and role-assignment write. The write condition fixes the role, principal ID and ServicePrincipal type. There is no role-assignment delete action. The target restriction lives in the protected policy definition. The module never grants the operational identities subscription RG write or subscription IAM reads, delegates RBAC administration, or installs a subscription-wide deny guard. Operators must protect the policy definitions, assignments and their managed identities.

The SNCloud (Test) experiment observed three direct workload grants per CE on both CEs. The automation identity then created both AKS clusters. Both automatic node Reader checks failed on each cluster because the caller could not read role assignments in its new sibling node group. On CE2 an installer update allowed the two intended policy identities to create Reader for automation and support. An installer intervention is still required for that control. Adding a later target to this verification allowlist requires an installer change. Unattended arbitrary future CEs and the proposed RG guard remain release gates. [Evidence and verification procedure](https://github.com/streamnative/snip/pull/148)

With the historical synthetic fixture, expose `module.onboarding.identity_metadata` as a Terraform root output and use the grant checker attached to the SNIP. Record installer commands and Terraform state before creating CE1 and after observing CE2. Inspect both workload and actual node scopes before any privileged control or remediation. When retiring the test, stop creating workloads, remove both test clusters and their RGs, verify policy-created grants have disappeared, then review a destroy plan for this module. Removing an assignment or a target does not revoke previously deployed Azure RBAC grants.

## Local checks

```sh
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

The Terraform tests use mock plans. They cover the single-input default, optional callback, exact workload and node targets, caller-dependent Reader gate, and rejection of unsafe settings.
