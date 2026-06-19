#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

mkdir -p $PREFIX
mkdir -p $BINDIR
chown -R $USERNAME:$GROUPNAME $PREFIX
