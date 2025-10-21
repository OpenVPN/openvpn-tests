#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

mkdir -p $PREFIX
mkdir -p $BINDIR
mkdir -p $OPENVPN_ETCDIR
chown -R $USERNAME:$GROUPNAME $PREFIX
