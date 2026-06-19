#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Make sure any systemd files we installed are read
systemctl daemon-reload

# Copy and modify anchor VMs OpenVPN client configuration file
mkdir -p "$OPENVPN_ETCDIR"
for config in anchor-200 anchor-207; do
    cp -v "$HOMEDIR/openvpn-tests/t_server/original/anchor_vm/openvpn.conf" "$OPENVPN_ETCDIR/${config}.conf"
    cp -v /root/openvpn-test-server/keys/ca.crt \
       "/root/openvpn-test-server/keys/${config}."* \
       "$OPENVPN_ETCDIR/"
    sed -i -e s/"^ca .*"/"ca ca.crt"/g \
        -e s/"^cert .*"/"cert ${config}.crt"/g \
        -e s/"^key .*"/"key ${config}.key"/g \
        -e s/"^remote .*"/"remote $ANCHOR_REMOTE"/g \
        "$OPENVPN_ETCDIR/${config}.conf"

    systemctl enable "tserver-setup-netns@${config}"
    systemctl enable "openvpn-client@${config}"
    systemctl restart "openvpn-client@${config}"
done
