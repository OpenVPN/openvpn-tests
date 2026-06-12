#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

mkdir -p $PLUGINDIR

cd $OPENVPN_GIT_REPO/sample/sample-plugins
cp -v client-connect/sample-client-connect.so $PLUGINDIR/
cp -v defer/multi-auth.so $PLUGINDIR/

cd $OPENVPN_GIT_REPO/src/plugins
cp -v down-root/.libs/openvpn-plugin-down-root.so $PLUGINDIR/
cp -v auth-pam/.libs/openvpn-plugin-auth-pam.so $PLUGINDIR/
