# openvpn_test_env

This is an OpenTofu root module that enables setting up several different things in AWS:

1. Server-side infrastructure for t_server
2. Manual OpenVPN test environments
3. Otterwiki
4. Buildbot

Each feature can be turned on and off as required. The main use-case is setting
up t_server infrastructure on-demand.

# Overview of the t_server setup

The t_server setup consists of three VMs:

* **t_server_rocky_9_amd64**: the server instance
* **t_server_client**: the client instance
* **t_server_anchor**: the anchor VM (=long-running OpenVPN client used in some t_client tests)

Each of these is configured with Tofu, which copies files and runs scripts on
them to configure them. Most things are implemented with cloud-init, but
OpenVPN certificates and keys are copied over with SSH-based provisioning to
avoid cloud-init user data from filling up completely.

It is possible to build this environment outside of AWS and/or without Tofu,
but in that case a lot of manual preparation is required. Once networks and VMs
are up, though, you should be able to just run the scripts that cloud-init runs
to configure your VMs according to their roles.

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
