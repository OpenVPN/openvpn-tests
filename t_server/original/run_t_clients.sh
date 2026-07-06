#!/bin/bash
#
set -u

. /var/lib/provision/deployment-config.sh

KEY=$SSH_PRIVATE_KEY
HOST=tserver-client.$PRIVATE_DNS_ZONE_NAME
TESTSETS="22 23 24 25 26 27 master"
TESTGROUPS=$(seq 1 10)

LOGDIR=$HOMEDIR/t_server_logs
DAY=`date +%Y%m%d`
NOW=`date +%Y%m%d-%H%M`

if [ ! -d "$LOGDIR/$DAY" ] ; then
    mkdir -p "$LOGDIR/$DAY"
fi

EXIT_CODE=0
SUMMARY=$LOGDIR/$DAY/$NOW.Summary
cat >$SUMMARY <<EOF
-----------------
Summary
-----------------
EOF
for T in $TESTSETS
do
    echo "$T..."
    JOBS=""
    for G in $TESTGROUPS
    do
        LOG=$LOGDIR/$DAY/$NOW.$T.$G.out

        echo "Starting $T/$G..."
        ssh -i "$KEY" "$HOST" "TEST_RUN_OVERRIDE='${TEST_RUN_OVERRIDE:-}' TEST_RUN_GROUP=$G ./bin/t_client.sh $T" >"$LOG" 2>&1 &
        JOBS="$JOBS $!"
    done
    echo "$T..." >> $SUMMARY
    G=1
    for J in $JOBS
    do
        LOG=$LOGDIR/$DAY/$NOW.$T.$G.out

        echo "Waiting for $T/$G (pid=$J)..."
        wait $J
        RC=$?
        echo "$T/$G..." >> $SUMMARY
        grep "Test sets" $LOG >> $SUMMARY
        case $RC in
	    0)  ;;	# all good
	    30) EXIT_CODE=1 ;;	# some tests failed
	    77) ;;      # no tests run
	    *)	# unexpected failure, show more details!
	        echo "Test run $T/$G failed (host=$HOST): rc=$RC" | tee -a $SUMMARY
	        echo "-----------------"
	        tail $LOG
	        echo "-----------------"
	        echo ""
	        exit 1
        esac
        G=$((G + 1))
    done
done

cat $SUMMARY
exit $EXIT_CODE
