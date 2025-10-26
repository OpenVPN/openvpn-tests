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
done
