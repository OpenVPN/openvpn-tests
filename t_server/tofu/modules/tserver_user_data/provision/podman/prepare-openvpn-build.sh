#!/bin/sh
set -e

BASEDIR="/build"

# Enable deb-src repos so that we can install OpenVPN build dependencies
# easily.  In recent Ubuntu versions apt sources are managed differently from
# old ones.
if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
    sed -i -E s/"^Types: .*"/"Types: deb deb-src"/g /etc/apt/sources.list.d/ubuntu.sources
else
    sed -i -E s/"^# (deb-src)"/"\1"/g /etc/apt/sources.list
    sed -i -E s/"(deb-src .*partner)$"/"# \1"/g /etc/apt/sources.list
fi

# Install OpenVPN build dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y build-dep openvpn
apt-get -y install \
automake \
autoconf \
git \
libnl-genl-3-dev \
libtool \
libpcap0.8-dev \
net-tools \
pkg-config

# Install t_client.sh dependencies
apt-get update
apt-get -y install \
dnsutils \
fping \
iproute2 \
sudo

# Clone OpenVPN
cd "$BASEDIR"
git clone https://github.com/OpenVPN/openvpn.git
