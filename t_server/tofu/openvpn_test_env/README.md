# openvpn_test_env

This is an OpenTofu root module that allows spinning up OpenVPN project
t_server testing environment with Tofu, the Terraform AWS provider and
cloud-init.

# Prerequisites

TODO

# Preparations

## Initializing the Tofu backend

Copy `backend.tfvars.sample` to `backend.tfvars`. Change the variables to point
to the AWS region and S3 bucket you created earlier. Then initialize the Tofu
backend with:

    tofu init -backend-config backend.tfvars
