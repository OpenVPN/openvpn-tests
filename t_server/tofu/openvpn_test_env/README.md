# openvpn_test_env

This is an OpenTofu root module that allows spinning up OpenVPN project
t_server testing environment with Tofu, the Terraform AWS provider and
cloud-init.

Building this setup is possible without touching Terraform or cloud-init, but
then a lot more manual preparation is required. The virtual machines that the
t_server setup requires can be configured with the same set of scripts that
cloud-init uses.

# Prerequisites

This root module has the following requirements:

* AWS S3 bucket for the OpenTofu state file
    * Make sure it is *not* publicly readable
* SSH keypair(s) for the Linux and Windows VMs
    * Windows only accepts RSA keypairs
    * Import it/them to your desired AWS region
* AWS user to use with OpenTofu
* AWS Route53 domain for public-facing service

# Required AWS IAM policies

The following built-in policies should be enough to spin up the environment:

* AmazonEC2FullAccess
* AmazonEventBridgeFullAccess
* AmazonRoute53FullAccess
* AmazonS3FullAccess
* AWSCertificateManagerFullAccess
* AWSLambda_FullAccess
* CloudFrontFullAccess
* CloudWatchFullAccessV2
* IAMFullAccess
    * If want to go fine-grained, do it here. Allowing full access to IAM is
      generally not a good idea security-vise.

# Preparations

## Create the AWS S3 backend variable file

Copy `backend.tfvars.sample` to `backend.tfvars`. Change the variables to point
to the AWS region and S3 bucket you created earlier.

## Initialize the Tofu backend

Initialize the Tofu backend with:

    tofu init -backend-config backend.tfvars

## Create OpenTofu variable file

Copy `input.auto.tfvars.sample` to `input.auto.tfvars` and modify it to match
your environment. The comments in that file should get you started.
