module "repo" {
  source    = "github.com/Puppet-Finland/terraform-cloudfront_bucket?ref=2.0.0"
  name      = "repo.singleion.com"
  tags      = { "Role": "Apt repository" }
  providers = { aws = aws,
  aws.us-east-1 = aws.us-east-1 }
}

resource "aws_acm_certificate" "repo" {
  provider          = aws.us-east-1
  domain_name       = "repo.singleion.com"
  validation_method = "DNS"
  tags              = { "Role": "Apt repository" }
}

