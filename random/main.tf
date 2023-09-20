terraform {

  required_providers {

    hashicorp-random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }

  required_version = ">= 1.1.0"
}


variable "name_length" {
  description = "The number of words in the pet name"
  type        = number
  default     = 3
}

resource "random_pet" "pet_name" {
  length    = var.name_length
  separator = "-"
}

output "pet_name" {
  value = random_pet.pet_name.id
}
