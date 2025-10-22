#!/bin/sh
#
set -e

# Set these variables manually if you run this script outside of Tofu
#
# git_name="John Doe"
# git_email="john.doe@example.org"

if [ x"${git_name}" != "x" ] && [ x"${git_email}" != "x" ]; then
    git config --global --replace-all user.name "${git_name}"
    git config --global --replace-all user.email "${git_email}"
fi
