#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Ensure that the containers can be passed a usable tun/tap device. Package
# "iproute2" is required for this to work.
if ! [ -f "/dev/net/tun" ]; then
  mkdir /dev/net
  mknod /dev/net/tun c 10 200
  ip tuntap add mode tap tap
fi
