#!/bin/sh
#
set -e

# Set up EPEL repository
if ! rpm -qa|grep -q epel-release-9; then
    curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -O
    rpm -i epel-release-latest-9.noarch.rpm
fi

# Set up CodeReady Builder repository as recommended by the Rocky Linux project
if crb status|grep -q "disabled"; then
    crb enable
fi

# Generic build dependencies
dnf -y install \
autoconf \
automake \
gcc \
gcc-c++ \
git \
make

# openvpn build dependencies
dnf -y install \
ccache \
fping \
inotify-tools-devel \
libcap-ng-devel \
libnl3-devel \
libtool \
lz4-devel \
lzo-devel \
pam-devel \
pkcs11-helper-devel \
pkgconfig \
openssl-devel

# ovpn-dco build dependencies
dnf -y install \
kernel-devel

# openssl build dependencies
dnf -y install \
perl-FindBin \
perl-Pod-Html

# t_server.sh dependencies
dnf -y install \
liboping \
libdb-utils

# Make sure that fping6 can be found
test -e /usr/sbin/fping6 || ln -s /usr/sbin/fping /usr/sbin/fping6

# Old OpenVPN version support with podman
dnf -y install \
podman \
skopeo

# Misc tools
dnf -y install \
bind-utils \
net-tools
