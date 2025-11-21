# openvpn_test_env

This is an OpenTofu root module for setting up the server-side infrastructure
for the t_server test environment. It should be possible to use Terraform for
the setup as well, but that has not been tested.

There are three "features" than can be toggled on and off as needed:

* VPC management
* Public DNS zone management
* Private DNS zone management

Letting this root module manage the private DNS zone simplifies the setup a
lot, but it also modifies VPC DHCP options. That may have unwanted side-effects
if you spin this thing up in an existing VPC. 

# Network architecture

In case you let this root module handle VPC configuration the end result will
look like this:

* Primary VPC
    * Public subnet
    * Private subnet

Private subnet only has a so-called "egress-only internet gateway", which means
that only IPv6 egress to Internet is possible. Public subnets have normal
Internet gateways and thus support both IPv4 and IPv6 egress. All EC2 instances
are created to the public subnet, so for the most part the private subnet can
be ignored.

There are two DNS zones which make working in the environment easier:

* **Public DNS zone**
    * Requires registering a domain in AWS Route53
    * Optional
* **Private DNS zone**
    * Does not require a domain registration as it is internal-only
    * Optional

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
* SSH keypair(s) for the Linux VMs
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
your environment. Some of the things you may need to change are:

* **manage_vpc**
    * Whether to let this root module create a new VPC; if set to false, set the *external* parameters accordingly
* **external_<option>**
    * Set these to match your existing VPC ID, public subnet ID and public subnet route table ID
* **enable_<feature>**
    * Turn off features you don't need
* **public_dns_zone_name**
    * Public DNS zone in Amazon Route53 where DNS records will be added
    * Must be a registered domain in Route53
* **private_dns_zone_name**
    * Private DNS zone name of your own choosing
    * Should *not* be a registered domain
* **key_name**
    * The name of the SSH key to use with Linux VMs
    * Must be present in the AWS EC2 region you chose in `input.auto.tfvars` and `provider.tf`
    * Can be an elliptic curve key
* **git_name** and **git_email**
    * These can be helpful when you modify this repository from the t_server server instance

Please refer to comments in [input.auto.tfvars.sample](input.auto.tfvars.sample) for details.

## Set AWS region

Currently you need to set the region in two places:

* *input.auto.tfvars*
* *provider.tf*

This inconvenience may be fixable.

# The t_server setup

The t_server setup consists of three VMs:

* **t_server_rocky_9_amd64**: the server instance
* **t_server_client**: the client instance
* **t_server_anchor**: the anchor VM (=long-running OpenVPN client used in some t_client tests)

These VMs are configured mainly with cloud-init *write_files* and *runcmd*
modules in the *tserver_user_data* Tofu module. However, OpenVPN certificates
and keys are copied over with SSH-based provisioning as they do not fit in the
cloud-init user data. Additionally there are a few files which are managed as
Tofu templates.

# Accessing the virtual machines

The *t_server_rocky_9_amd64* instance has an elastic IP (=static public IPv4
address) you can use for SSH connections. The other VMs don't have EIPs, but do
have public IPs.

A better option is of course to use a VPN and block public SSH access
altogether. For now the blocking part needs to be done from *sg.tf*.

# Deploying the environment outside of AWS

It is possible to build this environment outside of AWS and/or without Tofu,
but in that case a lot of manual preparation is required. Once networks and VMs
are up, though, you should be able to just run the scripts that cloud-init runs
to configure your VMs according to their roles. Refer to
`modules/tserver_user_data/main.tf` and `modules/tserver_user_data/provision`
for details.
