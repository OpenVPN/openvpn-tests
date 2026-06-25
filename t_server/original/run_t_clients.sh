#!/bin/sh
#
. /var/lib/provision/deployment-config.sh

KEY=$SSH_PRIVATE_KEY
HOST=tserver-client.$PRIVATE_DNS_ZONE_NAME
#TESTSETS="22 23.small 23 24 25 26 master"
TESTSETS="master"

LOGDIR=$HOMEDIR/t_server_logs
DAY=`date +%Y%m%d`
NOW=`date +%Y%m%d-%H%M`

if [ ! -d "$LOGDIR/$DAY" ] ; then
    mkdir -p "$LOGDIR/$DAY"
fi

for T in $TESTSETS
do
    echo "$T..."
    LOG=$LOGDIR/$DAY/$NOW.$T.out

    ssh -i $KEY $HOST "TEST_RUN_OVERRIDE='$TEST_RUN_OVERRIDE' ./bin/t_client.sh $T 2>&1" | tee $LOG
    RC=${PIPESTATUS[0]}
    case $RC in
	0)   grep "Test sets" $LOG ;;		# all good
	30)	# normal "one of the t_client tests failed", in "Test sets"
		grep "Test sets" $LOG ;;		# all good
	*)					# something else, more details!
	echo "SSH $HOST failed (test set $T): rc=$RC"
	echo "-----------------"
	tail $LOG
	echo "-----------------"
	echo ""
    esac
done
