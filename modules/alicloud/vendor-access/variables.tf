variable "sn_policy_version" {
  default = ""  
}

variable "organization_ids" {
  description = "The ID of your organization on StreamNative Cloud."
  type        = list(string)
}

variable "region" {
  default = "*"
  description = "The aliyun region where your StreamNative Cloud Environment can be deployed. Defaults to all regions."
}

variable "streamnative_cloud_manager_role_arns" {
  default = ["acs:ram::5855446584058772:role/cloud-manager"]
  description = "The list of StreamNative cloud manager role ARNs. This is used to grant StreamNative cloud manager to your environment."
  type        = list(string)
}



variable "streamnative_support_role_arns" {
  default = ["acs:ram::5855446584058772:role/support-general"]
  description = "The list of StreamNative support role ARNs. This is used to grant StreamNative support to your environment."
  type        = list(string)
}


# variable "buildin_roles" {
#   type = list(object({
#     name            = string
#     policy_document = string
#     description     = string
#     policy_name     = string
#   }))
#   default = [
#     {
#       name            = "AliyunCSManagedLogRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The logging component of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedLogRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedCmsRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The CMS component of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedCmsRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedCsiRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The volume plug-in of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedCsiRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedCsiPluginRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The volume plug-in of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedCsiPluginRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedCsiProvisionerRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The volume plug-in of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedCsiProvisionerRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedVKRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The VK component of ACK Serverless clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedVKRolePolicy"
#     },
#     {
#       name            = "AliyunCSServerlessKubernetesRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "By default, ACK clusters assume this role to access your cloud resources."
#       policy_name     = "AliyunCSServerlessKubernetesRolePolicy"
#     },
#     {
#       name            = "AliyunCSKubernetesAuditRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The auditing feature of ACK assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSKubernetesAuditRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedNetworkRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The network plug-in of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedNetworkRolePolicy"
#     },
#     {
#       name            = "AliyunCSDefaultRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "By default, ACK assumes this role to access your resources in other Alibaba Cloud services when managing ACK clusters."
#       policy_name     = "AliyunCSDefaultRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedKubernetesRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "By default, ACK clusters assume this role to access your cloud resources."
#       policy_name     = "AliyunCSManagedKubernetesRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedArmsRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The Application Real-Time Monitoring Service (ARMS) plug-in of ACK clusters assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedArmsRolePolicy"
#     },
#     {
#       name            = "AliyunCISDefaultRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "Container Intelligence Service (CIS) assumes this role to access your resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCISDefaultRolePolicy"
#     },
#     {
#       name            = "AliyunOOSLifecycleHook4CSRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"oos.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "Operation Orchestration Service (OOS) assumes this role to access your resources in other Alibaba Cloud services. ACK relies on OOS to scale node pools."
#       policy_name     = "AliyunOOSLifecycleHook4CSRolePolicy"
#     },
#     {
#       name            = "AliyunCSManagedAutoScalerRole"
#       policy_document = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"cs.aliyuncs.com\"]}}],\"Version\":\"1\"}"
#       description     = "The auto scaling component of ACK clusters assumes this role to access your node pool resources in other Alibaba Cloud services."
#       policy_name     = "AliyunCSManagedAutoScalerRolePolicy"
#     }
#   ]
# }