#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Copy files from openvpn-tests repo
cp -rv $OPENVPN_TESTS_GIT_REPO/t_server/original/client_vm/t_client.* $HOMEDIR/
cp -rv $OPENVPN_TESTS_GIT_REPO/t_server/original/client_vm/bin/* $BINDIR/

# Create a link to the "master" version of OpenVPN
test -e $BINDIR/openvpn.master || ln -s $BINDIR/openvpn $BINDIR/openvpn.master

# Modify t_client.rc files to match this environment. Variables come from
# deployment-config.sh.
REMOTE="$T_SERVER_HOSTNAME"

for V in 22 23 24 25 26 master; do
    F="$HOMEDIR/t_client.$V/t_client.rc"
    sed -i -E "s|KEYBASE=\".*\"|KEYBASE=\"$KEYDIR\"|" "$F"
    sed -i -E "s|CLIENT_KEY=\".*\"|CLIENT_KEY=\"\$KEYBASE/client-$V.key\"|" "$F"
    sed -i -E "s|CLIENT_CERT=\".*\"|CLIENT_CERT=\"\$KEYBASE/client-$V.crt\"|" "$F"
    sed -i -E "s|REMOTE=\".*\"|REMOTE=\"$REMOTE\"|" "$F"

    # Make sure that t_client_ips.rc is writeable by the default user and executable
    touch "$HOMEDIR/t_client.$V/t_client_ips.rc"
    chmod 755 "$HOMEDIR/t_client.$V/t_client_ips.rc"
done

# Add openvpn compatibility links for the volume mounts. These will not lead
# anywhere on the container host, but will on the containers.
ln -s /usr/local/bin/openvpn-27 $BINDIR/openvpn.master
ln -s /usr/local/bin/openvpn-27 $BINDIR/openvpn.27
ln -s /usr/local/bin/openvpn-26 $BINDIR/openvpn.26
ln -s /usr/local/bin/openvpn-25 $BINDIR/openvpn.25
ln -s /usr/local/bin/openvpn-24 $BINDIR/openvpn.24
ln -s /usr/local/bin/openvpn-23 $BINDIR/openvpn.23
ln -s /usr/local/bin/openvpn-22 $BINDIR/openvpn.22
