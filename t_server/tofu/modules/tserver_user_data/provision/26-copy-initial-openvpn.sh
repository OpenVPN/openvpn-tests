#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

test -x "$BINDIR/openvpn" || cp -v "$HOMEDIR/openvpn/src/openvpn/openvpn" "$BINDIR/"
