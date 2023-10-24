terraform {
  required_version = ">=1.2.0"

  required_providers {
    google = {
      version = ">= 4.60.0"
      source  = "hashicorp/google"
    }
  }
}
