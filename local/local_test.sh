#!/bin/bash

set -eux

pushd ../terraform/openvpn-server
CLIENT=$(terraform output -raw cn_client)
SERVER=$(terraform output -raw cn_server)
popd

OPENVPN_TESTS_PATH=/root/openvpn-test-server/openvpn-tests/local
SSH="ssh -o UserKnownHostsFile=known_hosts"

$SSH -o StrictHostKeyChecking=no "ubuntu@$SERVER" true
$SSH -o StrictHostKeyChecking=no "ubuntu@$CLIENT" true
$SSH "ubuntu@$SERVER" cloud-init status --wait
$SSH "ubuntu@$CLIENT" cloud-init status --wait

: ${IPERF_GLOBAL_SERVER_ARGS:=}
: ${IPERF_GLOBAL_CLIENT_ARGS:=-t10}
: ${RUN_NODCO:=true}
: ${RUN_DCO:=true}

LOG_DIR="testlogs-$(hostname)-$(date +%Y%m%d-%H%M%S)"
mkdir "$LOG_DIR"

TEST_COUNT=1

start_server() {
    TEST_NAME="$TEST_COUNT:$1"
    OVPN_ARGS="$2"
    $SSH "ubuntu@$SERVER" sudo $OPENVPN_TESTS_PATH/openvpn --cd $OPENVPN_TESTS_PATH/server \
        --config server.conf $OVPN_ARGS >"$LOG_DIR"/$TEST_NAME.ovpn_server.log 2>&1 &
    ovpn_server_ssh_pid=$!
    sleep 1
    $SSH "ubuntu@$SERVER" sudo iperf $IPERF_GLOBAL_SERVER_ARGS -s >"$LOG_DIR"/$TEST_NAME.iperf_server_tcp.log 2>&1 &
    $SSH "ubuntu@$SERVER" sudo iperf $IPERF_GLOBAL_SERVER_ARGS -u -s >"$LOG_DIR"/$TEST_NAME.iperf_server_udp.log 2>&1 &
}

start_client() {
    TEST_NAME="$TEST_COUNT:$1"
    OVPN_ARGS="$2"
    $SSH "ubuntu@$CLIENT" sudo $OPENVPN_TESTS_PATH/openvpn --cd $OPENVPN_TESTS_PATH/client \
        --config client.conf $OVPN_ARGS --remote "$SERVER" \
        >"$LOG_DIR"/$TEST_NAME.ovpn_client.log 2>&1 &
    ovpn_client_ssh_pid=$!
    sleep 5
    $SSH "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -c 10.199.2.1 >"$LOG_DIR"/$TEST_NAME.iperf_client_tcp.log 2>&1
    $SSH "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -u -c 10.199.2.1 >"$LOG_DIR"/$TEST_NAME.iperf_client_udp.log 2>&1
    $SSH "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -c "$SERVER" >"$LOG_DIR"/$TEST_NAME.iperf_client_novpn_tcp.log 2>&1
    $SSH "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -u -c "$SERVER" >"$LOG_DIR"/$TEST_NAME.iperf_client_novpn_udp.log 2>&1
}

deep_cleanup() {
    $SSH "ubuntu@$SERVER" sudo killall $OPENVPN_TESTS_PATH/openvpn || true
    $SSH "ubuntu@$SERVER" sudo killall iperf || true
    $SSH "ubuntu@$CLIENT" sudo killall $OPENVPN_TESTS_PATH/openvpn || true
    $SSH "ubuntu@$CLIENT" sudo killall iperf || true
    sleep 5
}

post_test_handler() {
    deep_cleanup
    echo "Test $TEST_COUNT COMPLETED"
    TEST_COUNT=$(( TEST_COUNT + 1 ))
}

retrieve_logs() {
    for log in syslog cloud-init-output.log; do
        scp -o UserKnownHostsFile=known_hosts "ubuntu@$SERVER":/var/log/$log "$LOG_DIR"/server.$log
        scp -o UserKnownHostsFile=known_hosts "ubuntu@$CLIENT":/var/log/$log "$LOG_DIR"/client.$log
    done
}
trap retrieve_logs EXIT

deep_cleanup

if $RUN_NODCO; then
    start_server nodco_udp "--disable-dco --proto udp6"
    start_client nodco_udp "--disable-dco --proto udp6"
    post_test_handler

    start_server nodco_tcp "--disable-dco --proto tcp6"
    start_client nodco_tcp "--disable-dco --proto tcp6"
    post_test_handler
fi

if $RUN_DCO; then
    start_server dco_udp "--proto udp6"
    start_client dco_udp "--proto udp6"
    post_test_handler

    start_server dco_tcp "--proto tcp6"
    start_client dco_tcp "--proto tcp6"
    post_test_handler
fi

deep_cleanup
