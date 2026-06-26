#!/bin/sh
#
# Reboot when deemed necessary. This is primarily meant for ovpn-dco, which
# cannot be built after kernel upgrades.

# RHEL 9 derivates use "needs-restarting" executable
if which needs-restarting > /dev/null 2>&1; then
    needs-restarting -r
    if [ $? -eq 1 ]; then
        # We don't want to restart right now, or cloud-init might think
        # something went wrong. Instead, we schedule a restart 10 seconds from
        # now.
        systemd-run --on-active=1 --timer-property=AccuracySec=100ms sh -c 'cloud-init status --wait ; systemctl reboot'
    fi
else
    # If we do not reboot, apply some settings
    systemctl restart systemd-sysctl.service
fi
