variable "project" {
  type        = string
  description = "The project id of the target project"
}

variable "roles" {
  default = [
    "roles/container.admin",
    "roles/StreamNativeCloudBootstrapRole"
  ]
  type        = list(string)
  description = "The role list will be associated with StreamNative GSA."
}

variable "bootstrap_permissions" {
  default = [
    "compute.globalAddresses.createInternal",
    "compute.globalAddresses.deleteInternal",
    "compute.globalAddresses.get",
    "compute.globalAddresses.setLabels",
    "compute.globalAddresses.use",
    "compute.globalForwardingRules.create",
    "compute.globalForwardingRules.delete",
    "compute.globalForwardingRules.get",
    "compute.globalForwardingRules.pscCreate",
    "compute.globalForwardingRules.pscDelete",
    "compute.globalOperations.get",
    "compute.instanceGroupManagers.get",
    "compute.networks.create",
    "compute.networks.delete",
    "compute.networks.get",
    "compute.networks.list",
    "compute.networks.updatePolicy",
    "compute.networks.use",
    "compute.regions.get",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.update",
    "compute.subnetworks.create",
    "compute.subnetworks.delete",
    "compute.subnetworks.get",
    "compute.zones.list",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.dnsKeys.get",
    "dns.dnsKeys.list",
    "dns.gkeClusters.bindDNSResponsePolicy",
    "dns.gkeClusters.bindPrivateDNSZone",
    "dns.managedZoneOperations.get",
    "dns.managedZoneOperations.list",
    "dns.managedZones.create",
    "dns.managedZones.delete",
    "dns.managedZones.get",
    "dns.managedZones.getIamPolicy",
    "dns.managedZones.list",
    "dns.managedZones.setIamPolicy",
    "dns.managedZones.update",
    "dns.networks.bindDNSResponsePolicy",
    "dns.networks.bindPrivateDNSPolicy",
    "dns.networks.bindPrivateDNSZone",
    "dns.networks.targetWithPeeringZone",
    "dns.networks.useHealthSignals",
    "dns.policies.create",
    "dns.policies.delete",
    "dns.policies.get",
    "dns.policies.list",
    "dns.policies.update",
    "dns.projects.get",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "dns.responsePolicies.create",
    "dns.responsePolicies.delete",
    "dns.responsePolicies.get",
    "dns.responsePolicies.list",
    "dns.responsePolicies.update",
    "dns.responsePolicyRules.create",
    "dns.responsePolicyRules.delete",
    "dns.responsePolicyRules.get",
    "dns.responsePolicyRules.list",
    "dns.responsePolicyRules.update",
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "servicedirectory.namespaces.create",
    "servicedirectory.namespaces.delete",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get"
  ]
  type        = list(string)
  description = "The list of permissions to grant to the to the StreamNative Cloud Bootstrap Role"
}




variable "streamnative_vendor_access_gsa" {
  default = [
    "cloud-manager@sncloud-production.iam.gserviceaccount.com",
    "pool-automation@sncloud-production.iam.gserviceaccount.com"
  ]
  type        = list(string)
  description = "The GSA will be used by StreamnNative cloud."
}

variable "streamnative_org_id" {
  default     = ""
  type        = string
  description = "Your Organization ID within StreamNative Cloud, used as name of impersonation GSA in your project. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  validation {
    condition = length(var.streamnative_org_id) <= 18
    error_message = "The organization ID must not exceed 18 characters. If you reach this limit, please contact StreamNative support."
  }
}

variable "streamnative_support_access_gsa" {
  default     = ["cloud-support-general@sncloud-production.iam.gserviceaccount.com"]
  type        = list(string)
  description = "The GSA will be used by StreamnNative support team."
}

variable "extra_google_services" {
  default     = []
  type        = list(string)
  description = "Extra google API services need to be enabled."
}
