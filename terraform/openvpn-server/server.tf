data "aws_ami" "ubuntu2204" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230711"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "cloudinit_config" "ubuntu_server" {
  gzip = false

  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      packages = [ "awscli", "git", "net-tools" ]
      package_update = true
      package_upgrade = false
      package_reboot_if_required = false
      write_files = [
        {
          path = "/root/openvpn-test-server/keys/ca.crt"
          content = module.pki.ca_cert
        },
        {
          path = "/root/openvpn-test-server/keys/server.crt"
          content = module.pki.server_cert
        },
        {
          path = "/root/openvpn-test-server/keys/server.key"
          content = module.pki.server_key
        },
        {
          path = "/root/openvpn-test-server/vars"
          content = <<EOF
OPENVPN_REPO=${var.openvpn_repo}
OPENVPN_BRANCH=${var.openvpn_branch}
OVPN_DCO_REPO=${var.ovpn_dco_repo}
OVPN_DCO_BRANCH=${var.ovpn_dco_branch}
TEST_REPO=${var.test_repo}
TEST_BRANCH=${var.test_branch}
EOF
        },
        {
          path = "/etc/sysctl.d/vpn.conf"
          content = <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF
        },

      ]
    })
  }
  part {
    content_type = "text/x-shellscript"
    filename = "install.sh"
    content = <<EOF
#!/bin/bash
set -eux

service procps restart

sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list

apt update
apt build-dep -y openvpn
apt install -y libnl-genl-3-dev libcap-ng-dev
apt install -y dkms # to get all kernel build deps

cd /root/openvpn-test-server

. ./vars

git clone -b $OPENVPN_BRANCH $OPENVPN_REPO openvpn
git clone -b $OVPN_DCO_BRANCH $OVPN_DCO_REPO ovpn-dco
git clone -b $TEST_BRANCH $TEST_REPO openvpn-tests
ln -s $PWD/openvpn/src/openvpn/openvpn openvpn-tests/server

pushd keys
openssl dhparam -out dh.pem 2048
popd

pushd openvpn

autoreconf -f -i
./configure
make -j4

popd
pushd ovpn-dco

make KERNEL_SRC=/lib/modules/$(uname -r)/build/
make install
modprobe ovpn-dco-v2

EOF
  }
}


module "server_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0.0"

  name = "${var.cluster_name}-server"

  associate_public_ip_address = true
  ami                    = data.aws_ami.ubuntu2204.id
  instance_type          = "m5.xlarge"
  ipv6_address_count     = 1
  key_name               = module.vpc.key_pair
  placement_group        = module.vpc.placement_group
  vpc_security_group_ids = [module.vpc.sg_id]
  subnet_id              = module.vpc.first_subnet
  user_data_base64       = data.cloudinit_config.ubuntu_server.rendered
  user_data_replace_on_change = false

  root_block_device = [
    {
      volume_size = 20
    },
  ]
}

data "aws_route53_zone" "selected" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "server_ipv4" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.cn
  type    = "A"
  ttl     = "60"
  records = [module.server_instance.public_ip]
}

resource "aws_route53_record" "server_ipv6" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.cn
  type    = "AAAA"
  ttl     = "60"
  records = module.server_instance.ipv6_addresses
}
