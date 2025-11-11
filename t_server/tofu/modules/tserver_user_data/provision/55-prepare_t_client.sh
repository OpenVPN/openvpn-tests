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
