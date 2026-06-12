#!/bin/sh
#
# Selinux fixes required by podman on tserver-client
#
set -e

. $(dirname "$0")/deployment-config.sh

# Without this selinux blocks device access from containers
setsebool -P  container_use_devices=true

# Configure selinux file context so that rootless podman can read and/or write
# files to volumes it needs to. The usual approach of mounting the volume with
# "z" flag does not work because podman lacks the permissions to change
# filesystem labels on the fly when the containers are started.
#
for d in $BINDIR /var/lib/provision /openvpn-test-server "$HOMEDIR/t_client.*"; do
    semanage fcontext -a -t container_file_t "$d(/.*)?"
    restorecon -F -R $d
done
