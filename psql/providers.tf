terraform {

  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.21.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "postgresql" {
  host     = var.dbhost
  port     = var.dbport
  username = var.dbroot_user
  sslmode  = var.sslmode

  clientcert {
    cert = var.ssl_cert
    key  = var.ssl_key
  }

  superuser = var.superuser
}