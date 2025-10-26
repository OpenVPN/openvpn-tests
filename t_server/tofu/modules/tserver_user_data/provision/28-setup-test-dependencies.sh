#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

# tun-tcp-p2mp: make sure --port-share can work
dnf -y install nginx
systemctl enable nginx
systemctl start nginx
mkdir -p /var/www/ps

# tun-tcp-p2mp: HTTP proxy for tests 1b and 1c
dnf -y install tinyproxy
# FIXME: get rid of hardcoded values
sed -i "/^Allow 127.0.0.1$/i Allow $T_SERVER_ALLOW_IPV4" /etc/tinyproxy/tinyproxy.conf
sed -i "/^Allow 127.0.0.1$/i Allow $T_SERVER_ALLOW_IPV6" /etc/tinyproxy/tinyproxy.conf
sed -i s/'^Port .*'/'Port 3128'/g /etc/tinyproxy/tinyproxy.conf
systemctl enable tinyproxy
systemctl restart tinyproxy

# tun-udp-p2mp: SOCKS proxy for tests 2d and 2e
dnf -y install dante-server
cp -v /etc/sockd.conf /etc/sockd.conf.vanilla

cat << EOF > /etc/sockd.conf
logoutput: syslog
user.privileged: root
user.unprivileged: nobody
# FIXME: remove hardcoded values
internal: eth0 port=1080
external: eth0
socksmethod: none
clientmethod: none
client pass { from: 0/0 to: 0/0 }
socks pass { from: 0/0 to: 0/0 }
EOF

systemctl enable sockd
systemctl restart sockd

# tun-udp-p2mp: fix hostname for "--local" directive so that bind does not fail
sed -i s/"^local .* 30003$"/"local $T_SERVER_HOSTNAME 30003"/g "$OPENVPN_TESTS_GIT_REPO/t_server/original/t_server/tun-udp-p2mp/server.conf"

# tun-udp-p2mp-hash-defscript: generate peer-fingerprint entries dynamically
for PEER in anchor client-27 client-26 client-25 client-24 client-23 client-22; do
    SERVER_CONF="$OPENVPN_TESTS_GIT_REPO/t_server/original/t_server/tun-udp-p2mp-hash-defscript/server.conf"
    FP="$(openssl x509 -fingerprint -sha256 -noout -in $KEYDIR/$PEER.crt|cut -d "=" -f 2)"
    grep -q $FP $SERVER_CONF || sed -i "/^<peer-fingerprint>$/a $FP" $SERVER_CONF
done

# tun-udp-p2mp-global-authpam: create pam_userdb
#
# https://www.chiark.greenend.org.uk/doc/libpam-doc/html/sag-pam_userdb.html
# https://linuxcommandlibrary.com/man/pam_userdb
#
# Both "auth" and "account" need to be present of authentication will fail. See
# "man pam_userdb" for details.
#
PAM_USERDB_DIR="$OPENVPN_TEST_SERVER_DIR/pam_userdb"
mkdir -p "$PAM_USERDB_DIR"
echo "auth required pam_userdb.so db=/openvpn-test-server/pam_userdb/users dump debug" > /etc/pam.d/openvpn-global
echo "account required pam_permit.so" >> /etc/pam.d/openvpn-global

cd "$PAM_USERDB_DIR"
echo john > users
echo password >> users
db_load -T -t hash -f users users.db
chmod 644 users users.db

# Ensure that tserver can connect to the clients with SSH
cp -v /var/lib/provision/orchestration-ssh-key $SSH_PRIVATE_KEY
chown $USERNAME:$GROUPNAME $SSH_PRIVATE_KEY
chmod 644 $SSH_PRIVATE_KEY
