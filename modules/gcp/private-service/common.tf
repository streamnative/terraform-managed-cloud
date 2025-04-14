variable "region" {
  type        = string
  description = "The GCP region where the private service connection will be configured."
}

variable "project" {
  type        = string
  description = "The GCP project where the private service connection will be configured."
}

variable "network_project" {
  type        = string
  description = "The GCP project where the shared VPC located in."
  default     = ""
}

variable "network_name" {
  type        = string
  description = "The GCP network where the private service connection will be available."
}

variable "subnet_name" {
  type        = string
  description = "The GCP subnet where the endpoint IP of private service connection will be allocated."
}

variable "domain_name" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.domain_name))
    error_message = "The domain name must be a valid DNS name."
  }
  description = "The base domain of private pulsar service."
}

variable "service_attachment" {
  type        = string
  default     = ""
  description = "The id of pulsar private service attachment."
}

variable "cross_region_access" {
  type        = bool
  default     = false
  description = "Allow access cross regions in the network."
}

variable "suffix" {
  description = "The suffix that will be part of the name of resources."
}


variable "service_attachments" {
  type = list(object({
    id   = string
    zone = string
  }))
  default     = []
  description = "The list of service attachments, only used when enable_topology_aware_gateway is true."
}
