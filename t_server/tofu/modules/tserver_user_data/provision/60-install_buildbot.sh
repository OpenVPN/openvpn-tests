#!/bin/bash
set -eux

. $(dirname "$0")/deployment-config.sh

dnf install -y python3-pip python3-virtualenv

mkdir -p /buildbot
chown -R "$USERNAME:$GROUPNAME" /buildbot

cd /buildbot
sudo -u "$USERNAME" virtualenv ./venv
sudo -u "$USERNAME" ./venv/bin/pip install buildbot-worker twisted
curl -sSfL https://raw.githubusercontent.com/OpenVPN/openvpn-buildbot/refs/heads/master/buildbot-host/buildbot.tac >buildbot.tac

systemctl daemon-reload
systemctl enable buildbot
systemctl start buildbot
