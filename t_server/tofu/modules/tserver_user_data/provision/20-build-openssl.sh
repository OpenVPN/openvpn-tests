#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

REF=OpenSSL_1_1_1w

cd $HOMEDIR/openssl

# Do not fail on the first build
make clean || true
git checkout $REF
./config --prefix=$PREFIX_OPENSSL_1_1_1W
make
make install
