terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = var.region
  max_retries = 1
  default_tags {
    tags = {
      Cluster     = var.cluster_name
      environment = var.environment
      owner       = var.owner
      maintainer  = var.email
      created-by  = "Terraform/OpenVPN/openvpn-tests/terraform/openvpn-server"
    }
  }
}

data "aws_caller_identity" "current" {}

module "pki" {
  source = "../openvpn-test-pki/"

  cn       = local.cn
  locality = var.cluster_name
  province = var.region
}

module "vpc" {
  source = "../openvpn-vpc-base/"

  name = var.cluster_name
  cidr_prefix = var.cidr_prefix
  ssh_pub_key = var.ssh_pub_key
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  cn             = "${var.dns_host_name}.${var.dns_zone_name}"
}
