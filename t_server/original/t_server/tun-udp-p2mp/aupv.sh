#!/bin/sh
echo "aupv USER: $username"
echo "aupv PASS: $password"

if [ "$username" = "" ] ; then
    # first call has no username/password (TLS cert auth only)
    # username + password is set by client-connect script
    echo "aupv first call"
    exit 0
fi

if [ "$password" = "" ] ; then
    echo "aupv USER is set, PASS is empty, FAIL" ; exit 1
fi

# our "token" is just a timestamp, valid 300 seconds
# (for real usage, this wants something authenticated)
EXPIRY=$(( $password + 300 ))
#EXPIRY=$(( $password + 120 ))
NOW=`date +%s`
echo "aupv EXPIRY: $EXPIRY, NOW: $NOW -> seconds left: " $(( $EXPIRY - $NOW ))
if [ "$EXPIRY" -le $NOW ] ; then
    echo "aupv token EXPIRED!"; exit 1
fi

exit 0
