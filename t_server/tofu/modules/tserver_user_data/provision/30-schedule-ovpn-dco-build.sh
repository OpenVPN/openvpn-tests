#!/bin/sh
#
# Schedule the build of ovpn-dco on the first boot. This cannot be done
# immediately as kernel packages tend to get upgraded by cloud-init and kernel
# headers and runtime kernel no longer match.
#
set -e

. $(dirname "$0")/deployment-config.sh

cp -v /var/lib/provision/build-ovpn-dco.sh "$BINDIR/"

UNIT_DIR="$HOMEDIR/.local/share/systemd/user"

mkdir -p "$UNIT_DIR"
cp -v /var/lib/provision/build-ovpn-dco.service "$UNIT_DIR/"

systemctl --user daemon-reload
systemctl --user enable build-ovpn-dco.service

loginctl enable-linger
