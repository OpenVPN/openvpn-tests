#!/bin/sh
#
if grep "Rocky Linux release 9." /etc/redhat-release > /dev/null 2>&1; then
    /var/lib/provision/install-openvpn-build-deps-rhel-9.sh
else
    echo "ERROR: unable to detect operating system!"
    exit 1
fi
