terraform {
  backend "s3" {
    bucket = "openvpn-foss-opentofu"
    region = "eu-central-1"
    key    = "production"
  }
}

