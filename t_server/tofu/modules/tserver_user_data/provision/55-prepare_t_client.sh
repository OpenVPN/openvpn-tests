#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Copy files from openvpn-tests repo
cp -rv $OPENVPN_TESTS_GIT_REPO/t_server/original/client_vm/t_client.* $HOMEDIR/
cp -rv $OPENVPN_TESTS_GIT_REPO/t_server/original/client_vm/bin/* $BINDIR/

# Rename t_client.sh as t_client.sh.real and use a podman wrapper in its place.
mv -v $BINDIR/t_client.sh $BINDIR/t_client.sh.real
cp -v /var/lib/provision/t_client.sh.wrapper $BINDIR/t_client.sh

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

# Create credentials files required by several tests
mkdir -p $OPENVPN_TEST_SERVER_DIR/auth
echo "fbsd-tc-master" > $OPENVPN_TEST_SERVER_DIR/auth/aup.txt
echo "totallysecret" >> $OPENVPN_TEST_SERVER_DIR/auth/aup.txt
echo "fbsd-tc-master" > $OPENVPN_TEST_SERVER_DIR/auth/aup-fail.txt
echo "wrongpassword" >> $OPENVPN_TEST_SERVER_DIR/auth/aup-fail.txt
