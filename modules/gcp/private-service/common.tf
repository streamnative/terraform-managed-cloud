variable "region" {
  type = string
  description = "The GCP region where the private service connection will be configured."
}

variable "network_name" {
  type = string
  description = "The GCP network where the private service connection will be available."
}

variable "subnet_name" {
  type = string
  description = "The GCP subnet where the endpoint IP of private service connection will be allocated."
}

variable "domain_name" {
  type = string
  description = "The base domain of private pulsar service."
}

variable "service_attachment" {
  type = string
  description = "The id of pulsar private service attachment."
}

variable "cross_region_access" {
  type = bool
  default = false
  description = "Allow access cross regions in the network."
}

variable "suffix" {
  description = "The suffix that will be part of the name of resources."
}
