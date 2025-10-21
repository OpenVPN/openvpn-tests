#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

cd $HOMEDIR/openvpn

autoreconf -vi
./configure
make
