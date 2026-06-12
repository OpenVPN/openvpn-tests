#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

cd "$KEYDIR"

if ! [ -f $KEYDIR/dh.pem ]; then
    openssl dhparam --out dh.pem 2048
fi
