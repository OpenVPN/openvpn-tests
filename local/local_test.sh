#!/bin/bash

set -eux

pushd ../terraform/openvpn-server
CLIENT=$(terraform output -raw cn_client)
SERVER=$(terraform output -raw cn_server)
popd

OPENVPN_TESTS_PATH=/root/openvpn-test-server/openvpn-tests/local

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
    ssh "ubuntu@$SERVER" cloud-init status --wait
    ssh "ubuntu@$SERVER" sudo $OPENVPN_TESTS_PATH/openvpn --cd $OPENVPN_TESTS_PATH/server \
        --config server.conf $OVPN_ARGS >"$LOG_DIR"/$TEST_NAME.ovpn_server.log 2>&1 &
    ovpn_server_ssh_pid=$!
    sleep 1
    ssh "ubuntu@$SERVER" sudo iperf $IPERF_GLOBAL_SERVER_ARGS -s >"$LOG_DIR"/$TEST_NAME.iperf_server_tcp.log 2>&1 &
    ssh "ubuntu@$SERVER" sudo iperf $IPERF_GLOBAL_SERVER_ARGS -u -s >"$LOG_DIR"/$TEST_NAME.iperf_server_udp.log 2>&1 &
}

start_client() {
    TEST_NAME="$TEST_COUNT:$1"
    OVPN_ARGS="$2"
    ssh "ubuntu@$CLIENT" cloud-init status --wait
    ssh "ubuntu@$CLIENT" sudo $OPENVPN_TESTS_PATH/openvpn --cd $OPENVPN_TESTS_PATH/client \
        --config client.conf $OVPN_ARGS --remote "$SERVER" \
        >"$LOG_DIR"/$TEST_NAME.ovpn_client.log 2>&1 &
    ovpn_client_ssh_pid=$!
    sleep 5
    ssh "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -c 10.199.2.1 >"$LOG_DIR"/$TEST_NAME.iperf_client_tcp.log 2>&1
    ssh "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -u -c 10.199.2.1 >"$LOG_DIR"/$TEST_NAME.iperf_client_udp.log 2>&1
    ssh "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -c "$SERVER" >"$LOG_DIR"/$TEST_NAME.iperf_client_novpn_tcp.log 2>&1
    ssh "ubuntu@$CLIENT" sudo iperf $IPERF_GLOBAL_CLIENT_ARGS -u -c "$SERVER" >"$LOG_DIR"/$TEST_NAME.iperf_client_novpn_udp.log 2>&1
}

deep_cleanup() {
    ssh "ubuntu@$SERVER" sudo killall $OPENVPN_TESTS_PATH/openvpn || true
    ssh "ubuntu@$SERVER" sudo killall iperf || true
    ssh "ubuntu@$CLIENT" sudo killall $OPENVPN_TESTS_PATH/openvpn || true
    ssh "ubuntu@$CLIENT" sudo killall iperf || true
    sleep 5
}

post_test_handler() {
    deep_cleanup
    echo "Test $TEST_COUNT COMPLETED"
    TEST_COUNT=$(( TEST_COUNT + 1 ))
}

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
