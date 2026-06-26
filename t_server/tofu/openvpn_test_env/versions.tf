terraform {
  required_version = ">= 1.10, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.97.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "= 2.3.7"
    }
    tls = {
      source = "hashicorp/tls"
      version = "=4.1.0"
    }
    sshkey = {
      source = "daveadams/sshkey"
      version = "=0.2.1"
    }
  }
}
