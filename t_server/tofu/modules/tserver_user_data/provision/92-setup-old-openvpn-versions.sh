#!/bin/sh
set -e

. $(dirname "$0")/deployment-config.sh

# Build the software museum
cd /var/lib/provision/podman
podman build -f Containerfile.ubuntu-14.04 -t openvpn-22 -t openvpn-23 .
podman build -f Containerfile.ubuntu-20.04 -t openvpn-24 -t openvpn-25 .
podman build -f Containerfile.ubuntu-24.04 -t openvpn-26 -t openvpn-27 .
