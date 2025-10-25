# openvpn_test_env

This is an OpenTofu root module that enables setting up several different things in AWS:

1. Server-side infrastructure for t_server
2. Manual OpenVPN test environment
3. Otterwiki
4. Buildbot

Each feature can be turned on and off as required. The main use-case is setting
up t_server infrastructure on-demand.

# Network architecture

The network setup looks roughly like this:

* Primary VPC ("production")
    * Public subnet
    * Private subnet
* Secondary VPC ("office")
    * Public subnet
    * Private subnet

These two VPC are completely detached from each other. Connectivity between the
two is meant to be provided by OpenVPN servers used for manual testing.

Private subnets only have so-called "egress-only internet gateways", which
means that only IPv6 egress to Internet is possible. Public subnets have normal
Internet gateways and thus support both IPv4 and IPv6 egress.

There are two DNS zones which make working in the environment easier:

* **Public DNS zone**
    * Requires registering a domain in AWS Route53
    * Optional, although turning it off *may* require fixes to Tofu code)
* **Private DNS zone**
    * Does not require a domain registration as it is internal-only

## Tofu modules

* **The root module**: sets up virtual machines, DNS zones and records, security groups, additional routing rules, etc.
* **opentofu-vpc**: handles creation of all the AWS VPC plumbing, internet gateways, etc.
* **ami**: provides latest AMIs for various operating systems
* **scheduler-stop-start**: allows automatically stopping the EC2 instances in the evening when tag "tostop" is "true"; uses [diodonfrost/terraform-aws-lambda-scheduler-stop-start](https://github.com/diodonfrost/terraform-aws-lambda-scheduler-stop-start) under the hood
* **openvpn-test-pki**: the PKI used by tserver, tserver-client and tserver-anchor
* **tserver_user_data**: creates user data dynamically for each tserver instance according to their role (server, client, anchor)

## Prerequisites

Th root module has the following requirements:

* AWS S3 bucket for the OpenTofu state file
    * Make sure it is *not* publicly readable
* SSH keypair(s) for the Linux and Windows VMs
    * Windows only accepts RSA keypairs
    * Import it/them to your desired AWS region
* AWS keypair to use with OpenTofu
    * Usually associated with an IAM user with enough permissions (see below)
* AWS Route53 domain for public-facing service

## Required AWS IAM policies

The following built-in policies should be enough to spin up the environment:

* AmazonEC2FullAccess
* AmazonEventBridgeFullAccess
* AmazonRoute53FullAccess
* AmazonS3FullAccess
* AWSCertificateManagerFullAccess
* AWSLambda_FullAccess
* CloudWatchFullAccessV2
* IAMFullAccess
    * If want to go fine-grained, do it here. Allowing full access to IAM is
      generally not a good idea security-vise.

## Preparations

### Create the AWS S3 backend variable file

Copy `backend.tfvars.sample` to `backend.tfvars`. Change the variables to point
to the AWS region and S3 bucket you created earlier.

### Initialize the Tofu backend

Initialize the Tofu backend with:

    tofu init -backend-config backend.tfvars

### Create OpenTofu variable file

Copy `input.auto.tfvars.sample` to `input.auto.tfvars` and modify it to match
your environment. The things you may need to change are:

* **enable_<feature>**
    * Turn off features you don't need (e.g. the manual OpenVPN testing environment)
* **public_dns_zone_name**
    * Public DNS zone in Amazon Route53 where DNS records will be added
    * Must be a registered domain in Route53
* **private_dns_zone_name**
    * Private DNS zone name of your own choosing
    * Should not be a registered domain
* **key_name**
    * The name of the SSH key to use with Linux VMs
    * Must be present in the AWS EC2 region you chose in `backend.tfvars`
    * Can be an elliptic curve key
* **windows_key_name**
    * The name of the SSH key to use with Windows VMs
    * Must be present in the AWS EC2 region you chose in `backend.tfvars`
    * Must be an RSA key
* **tserver_allow_ipv6**
    * Should match the AWS-generated IPv6 subnet of your VPC, which you will only know after deploying the VPC
* **git_name** and **git_email**
    * These can be helpful when you modify this repository from the t_server server instance

# The t_server setup

The t_server setup consists of three VMs:

* **t_server_rocky_9_amd64**: the server instance
* **t_server_client**: the client instance
* **t_server_anchor**: the anchor VM (=long-running OpenVPN client used in some t_client tests)

These VMs are configured mainly with cloud-init *write_files* and *runcmd*
modules in the *tserver_user_data* Tofu module. However, OpenVPN certificates
and keys are copied over with SSH-based provisioning as they do not fit in the
cloud-init user data.  Additionally there are a few files which are managed as
Tofu templates.

It is possible to build this environment outside of AWS and/or without Tofu,
but in that case a lot of manual preparation is required. Once networks and VMs
are up, though, you should be able to just run the scripts that cloud-init runs
to configure your VMs according to their roles. Refer to
`modules/tserver_user_data/main.tf` and `modules/tserver_user_data/provision`
for details.

# Manual OpenVPN test environment

The manual OpenVPN test setup doubles as a remote access solution to the
t_server test setup. It consists of a number of OpenVPN servers, client and
support VMs:

* Rocky Linux 9 OpenVPN setup
    * **openvpn_rocky_9**: an OpenVPN server based on Rocky Linux 9
    * **openvpn_client**: an OpenVPN client for this server
* Ubuntu 24.04 OpenVPN setup
    * **openvpn_ubuntu_2404**: an OpenVPN server based on Ubuntu 24.04
    * **openvpn_client_ubuntu_2404**: an OpenVPN client for this server
* Windows Server 2025 base OpenVPN setup
    * **openvpn_windows**: an OpenVPN server based on Windows Server Base 2025
    * **openvpn_client_windows**: an OpenVPN client for this server
* **office_server**: an OpenVPN client in a different, public subnet that should be reachable through any of the above VPNs; mainly meant for iroute testing
* **private_office_server**: an OpenVPN client in a different, private subnet that should be reachable through any of the above VPNs; mainly meant for iroute testing

The VPN CIDR blocks for each OpenVPN server must be configured in
`input.auto.tfvars` so that return packets can find their way to the OpenVPN
clients. These servers are configured with Ansible code that is not currently
stored in this repository.

# Otterwiki

This server is an testing/staging instance for the community.openvpn.net
Otterwiki instance. It is managed by Puppet Bolt code that is not currently
stored in this repository.

# Buildbot

This server is an testing/staging instance for the OpenVPN community buildbot.
It can be configured with the normal bootstrapping scripts in openvpn-buildbot
repository.
