#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Copy and modify anchor VMs OpenVPN client configuration file
if ! [ -f "$OPENVPN_ETCDIR/anchor.conf" ]; then
    mkdir -p "$OPENVPN_ETCDIR"
    cp -v "$HOMEDIR/openvpn-tests/t_server/original/anchor_vm/openvpn.conf" "$OPENVPN_ETCDIR/anchor.conf"
    sed -i s/"^ca .*"/"ca \/root\/openvpn-test-server\/keys\/ca.crt"/g "$OPENVPN_ETCDIR/anchor.conf"
    sed -i s/"^cert .*"/"cert \/root\/openvpn-test-server\/keys\/anchor.crt"/g "$OPENVPN_ETCDIR/anchor.conf"
    sed -i s/"^key .*"/"key \/root\/openvpn-test-server\/keys\/anchor.key"/g "$OPENVPN_ETCDIR/anchor.conf"
    sed -i s/"^remote .*"/"remote $ANCHOR_REMOTE"/g "$OPENVPN_ETCDIR/anchor.conf"
fi
