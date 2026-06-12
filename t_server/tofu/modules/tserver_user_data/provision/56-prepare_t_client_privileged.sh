#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Add openvpn compatibility links for the volume mounts. These will not lead
# anywhere on the container host, but will on the containers.
for v in 22 23 24 25 26 27 master; do
    test -L $BINDIR/openvpn.$v || ln -s /usr/local/bin/openvpn-$v $BINDIR/openvpn.$v
done

# Ensure that the containers can be passed a usable tun/tap device. Package
# "iproute2" is required for this to work.
if ! [ -f "/dev/net/tun" ]; then
  mkdir /dev/net
  mknod /dev/net/tun c 10 200
  ip tuntap add mode tap tap
fi
