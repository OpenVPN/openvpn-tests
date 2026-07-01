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

SUMMARY=$LOGDIR/$DAY/$NOW.Summary
cat >$SUMMARY <<EOF
-----------------
Summary
-----------------
EOF
for T in $TESTSETS
do
    echo "$T..."
    LOG=$LOGDIR/$DAY/$NOW.$T.out

    ssh -i $KEY $HOST "TEST_RUN_OVERRIDE='$TEST_RUN_OVERRIDE' ./bin/t_client.sh $T 2>&1" | tee $LOG
    echo "$T..." >> $SUMMARY
    grep "Test sets" $LOG >> $SUMMARY
    RC=${PIPESTATUS[0]}
    case $RC in
	0)  ;;	# all good
	30) ;;	# all good
	*)	# something else, more details!
	echo "SSH $HOST failed (test set $T): rc=$RC" | tee -a $SUMMARY
	echo "-----------------"
	tail $LOG
	echo "-----------------"
	echo ""
	exit 1
    esac
done

cat $SUMMARY
