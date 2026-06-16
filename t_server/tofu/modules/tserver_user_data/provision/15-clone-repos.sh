#!/bin/sh
#
set -e

. "$(dirname "$0")/deployment-config.sh"

PATH=/bin:/usr/bin:/sbin:/usr/sbin

echo "Cloning repositories to $HOMEDIR"
cd $HOMEDIR

REPOS="https://github.com/OpenVPN/openvpn.git \
https://github.com/OpenVPN/ovpn-dco.git \
https://github.com/OpenVPN/openvpn-tests.git \
https://github.com/openssl/openssl.git"

for REPO in $REPOS; do
    REPONAME=$(basename $REPO .git|awk -F"/" '{print $NF}')
    if [ -d $REPONAME ]; then
	echo "Repository $REPO is already present, skipping..."
    else
        git clone $REPO
	chown -R $USERNAME:$GROUPNAME $REPONAME
    fi
done
