#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# Copy files from openvpn-tests repo
cp -rLv $OPENVPN_TESTS_GIT_REPO/t_server/original/client_vm/t_client.* $HOMEDIR/
cp -rv $OPENVPN_TESTS_GIT_REPO/t_server/original/client_vm/bin/* $BINDIR/

# Rename t_client.sh as t_client.sh.real and use a podman wrapper in its place.
mv -v $BINDIR/t_client.sh $BINDIR/t_client.sh.real
cp -v /var/lib/provision/t_client.sh.wrapper $BINDIR/t_client.sh

# Modify t_client.rc files to match this environment. Variables come from
# deployment-config.sh.
REMOTE="$T_SERVER_HOSTNAME"

for V in 22 23 24 25 26 27 master; do
    F="$HOMEDIR/t_client.$V/t_client.rc"
    sed -i -E "s|KEYBASE=\".*\"|KEYBASE=\"$KEYDIR\"|" "$F"
    sed -i -E "s|CLIENT_KEY=\".*\"|CLIENT_KEY=\"\$KEYBASE/client-$V.key\"|" "$F"
    sed -i -E "s|CLIENT_CERT=\".*\"|CLIENT_CERT=\"\$KEYBASE/client-$V.crt\"|" "$F"
    sed -i -E "s|REMOTE=\".*\"|REMOTE=\"$REMOTE\"|" "$F"

    # Make sure that t_client_ips.rc is writeable by the default user
    touch "$HOMEDIR/t_client.$V/t_client_ips.rc"
done

# Create credentials files required by several tests
mkdir -p $OPENVPN_TEST_SERVER_DIR/auth
USERS_DB=$OPENVPN_TESTS_GIT_REPO/t_server/original/t_server/users.txt
grep -A1 "^fbsd-tc-master" $USERS_DB > $OPENVPN_TEST_SERVER_DIR/auth/aup.txt
echo "<auth-user-pass>" > $OPENVPN_TEST_SERVER_DIR/auth/aup.conf
cat $OPENVPN_TEST_SERVER_DIR/auth/aup.txt >> $OPENVPN_TEST_SERVER_DIR/auth/aup.conf
echo "</auth-user-pass>" >> $OPENVPN_TEST_SERVER_DIR/auth/aup.conf
echo "fbsd-tc-master" > $OPENVPN_TEST_SERVER_DIR/auth/aup-fail.txt
echo "wrongpassword" >> $OPENVPN_TEST_SERVER_DIR/auth/aup-fail.txt
# here we use the correct password, but a longer username. This is to test for an issue
# where we truncated the username silently
echo "ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_ThisUserNameIsTooLongReally_230ch" > $OPENVPN_TEST_SERVER_DIR/auth/aup-toolong.txt
grep -A1 "^ThisUserNameIsTooLongReally_" $USERS_DB | tail -n1 >> $OPENVPN_TEST_SERVER_DIR/auth/aup-toolong.txt
