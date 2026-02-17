variable "region" {
  type        = string
  description = "The region of vpc endpoint to be created. This should be the same as the region of the VPC."
}

variable "service_region" {
  type        = string
  description = "The region of the VPC endpoint service. The VPC Endpoint can be in a different region, will fallback to the VPC endpoint region if not specified."
  default = ""
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in which the endpoint will be used"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ID of one or more subnets in which to create a network interface for the endpoint. Must be the same AZ as Endpoint Service."
}

variable "service_name" {
  type        = string
  description = "The vpc endpoint service name"
}

variable "security_group_ids" {
  type        = list(string)
  default     = null
  description = "The ID of one or more security groups to associate with the network interface. If unspecified, will auto-create one"
}

variable "name" {
  type        = string
  default     = ""
  description = "The endpoint name"
}