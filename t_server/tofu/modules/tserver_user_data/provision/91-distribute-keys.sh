#!/bin/sh
#

. $(dirname "$0")/deployment-config.sh

KNOWN_HOSTS="$HOMEDIR/.ssh/known_hosts"
test -f $KNOWN_HOSTS && mv -vb $KNOWN_HOSTS $KNOWN_HOSTS.bak

# These DNS entries are expected to resolve
for SERVER in tserver-client tserver-anchor; do
    # The tserver nodes may get rebuilt, so we can't count on having static
    # host keys. Therefore we refetch them every time this script runs (which
    # normally would be just once, or when explicitly requested.

    ssh-keyscan $SERVER > $KNOWN_HOSTS 2> /dev/null

    # Wait until the target is reachable. This does not always seem to be the case.
    count=0
    maxcount=60
    while [ $count -le $maxcount ]; do
      count=$(( count + 1 ))
      ssh $USERNAME@$SERVER "echo Connected to $SERVER" && break
      sleep 10
    done
    # Synchronize the keys. This should work as long as the keydir is present
    # and is writeable on the client and anchor VMs when this script runs. That
    # should always be the case as it gets created very early on.
    rsync -va $KEYDIR/ta*.key $KEYDIR/tc*.key $USERNAME@$SERVER:$KEYDIR/
done
