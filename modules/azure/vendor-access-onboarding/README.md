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

The verification targets enable a subscription-scoped custom role for each policy identity with deployment permissions and role-assignment write. The write condition fixes the role, principal ID and ServicePrincipal type. There is no role-assignment delete action. The target restriction lives in the protected policy definition. This fixed-target profile grants the operational identities neither subscription RG write nor subscription IAM reads, and installs no subscription-wide deny guard. Operators must protect the policy definitions, assignments and their managed identities.

The SNCloud (Test) experiment observed three direct workload grants per CE on both CEs. The automation identity then created both AKS clusters. Both automatic node Reader checks failed on each cluster because the caller could not read role assignments in its new sibling node group. On CE2 an installer update allowed the two intended policy identities to create Reader for automation and support. An installer intervention is still required for that control. Adding a later target to this verification allowlist requires an installer change. Unattended arbitrary future CEs and the proposed RG guard remain release gates. [Evidence and verification procedure](https://github.com/streamnative/snip/pull/148)

With the historical synthetic fixture, expose `module.onboarding.identity_metadata` as a Terraform root output and use the grant checker attached to the SNIP. Record installer commands and Terraform state before creating CE1 and after observing CE2. Inspect both workload and actual node scopes before any privileged control or remediation. When retiring the test, stop creating workloads, remove both test clusters and their RGs, verify policy-created grants have disappeared, then review a destroy plan for this module. Removing an assignment or a target does not revoke previously deployed Azure RBAC grants.

## Verify a future CE without another installer apply

This separate experimental profile requires an **empty dedicated disposable subscription**. Do not enable it in the shared SNCloud (Test) subscription used for the earlier experiment. It installs a subscription-wide RG deny policy that affects every caller, including the installer. The first apply rejects any existing RG, and the supplied subscription UUID must equal the authenticated provider subscription. Use a fresh root module and state. Converting an existing installation to this profile is unsupported.

```hcl
environment                = "test"
bootstrap_location         = "eastus"
disposable_subscription_id = "<the selected empty disposable subscription UUID>"
# verification_targets must remain empty. Future CE UIDs are unknown at apply.
enable_node_reader_verification = true
# Leave false to reproduce the caller-read failure. A separate comparator run
# may set true BEFORE recording the installer baseline and before creating CE1.
enable_caller_role_assignment_read_comparator = false
```

This profile couples automation's subscription `resourceGroups/read` and `resourceGroups/write` grant to the deny guard. It grants no subscription RG delete and no operational RBAC write. The guard allows the protected manager RG, correctly named/tagged workload RGs in `eastus`, and the reserved `MC_snce-<namespace>-eastus-*` node-group namespace. The node namespace allows AKS to create its group without workload tags. That exception is namespace-based and does not authenticate the RG creator. The three workload policies select future canonical CE UIDs without an installer allowlist. The node policies use the actual AKS `nodeResourceGroup` response, restricted to `MC_<that workload RG>_*`. The current Azure module uses that AKS naming convention. The experiment does not support a custom node RG name.

Terraform ordering only ensures the guard assignment exists before the RG-create grant is assigned. It does not prove policy propagation. Before using automation, manually verify the active deny guard rejects an unrelated RG name and wrong/missing workload tags. Stop if either negative case succeeds. Do not create workloads during the policy propagation window. The automation role can update the manager RG metadata, although it has no additional access to the resources inside it. It can also create arbitrary RGs within the permitted `MC_<namespace>eastus-*` namespace. This global namespace constraint does not authenticate a caller or establish ownership of a CE or node group. Those gaps, policy propagation, and concurrent privileged namespace creation remain production release blockers. The empty disposable subscription requirement bounds this experiment's impact.

The optional caller-read comparator grants **only** `Microsoft.Authorization/roleAssignments/read` to automation at subscription scope. It exposes assignment metadata across that disposable subscription. It adds no role-definition read, general Reader, or IAM write. This is a hypothesis to test, not a previously observed fix. Azure documents that the original caller evaluates the DINE existence condition while the policy identity deploys the template. [Azure Policy assignment identity](https://learn.microsoft.com/en-gb/azure/governance/policy/concepts/assignment-structure)

For a manual run, keep the selected profile and comparator value fixed across CE1 and CE2. Record the installer state serial, resource list, outputs, plan and command log immediately after apply. Use the paired Argo branch's `previews/create_azure_workload_group.py` to create CE1's canonical RG and wait for all three direct grants. With no subscription IAM-read grant, this first automation RG PUT may itself fail the workload DINE existence read. The earlier successful workload-grant test used installer-created groups. Stop on failed workload grants and preserve the untreated result. The explicit comparator tests both workload and node evaluation.

The paired Argo branch's `previews/create_azure_aks_fixture.py` and `previews/README.md` provide an offline request generator, automation-only conditional submission, and status commands for a private single-node AKS fixture. It requires a reviewed regional Kubernetes patch version, VM size/quota and an RSA public key. It omits a node RG override and uses the actual Azure response for subsequent checks. Create it only after all workload grants are effective, then wait for both direct node Reader grants before probing both identities against VMSS and metrics. Create CE2 with a fresh UID chosen **after** the installer baseline. Repeat without Terraform plan/apply, installer RG PUT, remediation, or privileged role assignment between baseline and CE2. Read-only installer observations are allowed. Save failed automatic observations before any diagnostic control. A passing workload-only run does not prove node access, and a bare AKS fixture does not prove the full service Terraform path, which also creates scoped service role assignments.

These future-CE policies, the deny guard and the comparator have only local mock-plan coverage. They have not been exercised against Azure. The earlier SNCloud (Test) evidence remains a fixed-target experiment with failed automatic node access. Retire the fixture workloads and node groups first. Then destroy the module, which removes the RG-create assignment before the guard. Do not remove the guard while an automation RG-create assignment remains effective.

## Local checks

```sh
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
python3 -B -m unittest discover -s tests -p 'test_*.py'
```

The Terraform tests use mock plans. They cover the single-input default, optional callback, exact workload and node targets, future CE matching, guarded RG write, the explicit caller-read comparator, and rejection of unsafe profile settings. Mock plans do not evaluate Azure Policy expressions or prove effective Azure permissions.
