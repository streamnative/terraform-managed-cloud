variable "source_project" {
  type        = string
  description = "The gcp project which holds the parent zone"
}

variable "target_project" {
  type        = string
  description = "The gcp project which holds the new zone"
}

variable "source_zone_name" {
  type        = string
  description = "The parent zone in which create the delegation records"
}

variable "target_zone_name" {
  type        = string
  description = "The new zone name"
}

variable "target_zone_dns_name" {
  type        = string
  description = "The new DNS name"

  validation {
    condition     = endswith(var.target_zone_dns_name, ".")
    error_message = "DNS name must end with '.'"
  }
}
