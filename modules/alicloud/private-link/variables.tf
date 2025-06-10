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
  type = list(object({
    id   = string
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
  default     = []
}

variable "use_existing_security_group" {
  description = "Flag to indicate whether to use existing security groups or create new ones."
  type        = bool
  default     = false
}

variable "security_group_inbound_rules" {
  description = "List of inbound rules for the security group."
  type = list(object({
    port        = number
    description = string
  }))
  default = [
    {
      port        = 443,
      description = "Allow HTTPS traffic to the endpoint"
    },
    {
      port        = 6651,
      description = "Allow Pulsar traffic to the endpoint"
    },
    {
      port        = 9093,
      description = "Allow Kafka traffic to the endpoint"
    },
    {
      port        = 5671,
      description = "Allow AMQP traffic to the endpoint"
    },
    {
      port        = 5672,
      description = "Allow AMQP traffic to the endpoint"
    },
    {
      port        = 8883,
      description = "Allow MQTT traffic to the endpoint"
    }
  ]
}
