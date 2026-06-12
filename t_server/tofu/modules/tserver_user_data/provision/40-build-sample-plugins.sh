#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

cd $OPENVPN_GIT_REPO/sample/sample-plugins
gmake client-connect/sample-client-connect.so
gmake defer/multi-auth.so
