#!/bin/sh
set -e

BRANCH=$1
SUFFIX=$2

git checkout $BRANCH || git checkout -b $BRANCH origin/$BRANCH
autoreconf -vi
./configure
make -j2

# The executable location is not static when we go back far enough in history
EXE=$(find . -type f -name "openvpn" -perm 0755 -mmin -1)

# Validate that the openvpn executable is present
if [ x"$EXE" = "x" ]; then
    echo "ERROR: openvpn executable not found"
    exit 1
fi

# Output version and compile options. This exits with non-zero exit status in
# some cases, so we can't use it to validate that the executable works.
$EXE --version || true

cp -v $EXE /usr/local/bin/openvpn-$SUFFIX
make clean

git checkout master
