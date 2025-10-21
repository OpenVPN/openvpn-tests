#!/bin/sh
#
set -e

. /var/lib/provision/deployment-config.sh

PLACEHOLDER="$HOMEDIR/.build-ovpn-dco.sh-has_run"

if [ -f "$PLACEHOLDER" ]; then
    exit 0
fi

cd $HOMEDIR/ovpn-dco

make

touch "$PLACEHOLDER"
