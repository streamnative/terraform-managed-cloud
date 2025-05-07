terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "1.248.0"
    }
  }
}

variable "vpc_id" {
  description = "The ID of the VPC to create the endpoint in."
  type        = string
}

variable "privatelink_service_id" {
  description = "The ID of the PrivateLink service."
  type        = string
}

variable "endpoint_name" {
  description = "The name of the VPC endpoint."
  type        = string
}

variable "vswitches" {
  description = "The list of VSwitch IDs to associate with the endpoint."
  type        = list(object({
    id     = string
    zone = string
  }))
}

variable "domain_name" {
  description = "The domain suffix used by the service."
  type        = string
}


variable "security_group_ids" {
  description = "The list of security group IDs to associate with the endpoint."
  type        = list(string)
}