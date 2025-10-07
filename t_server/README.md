# Introduction

This is an attempt to document the OpenVPN project's "t_server" testbed(s), and
make it accessible to others.

The mid-term plan is to see if it can be templated, so you can checkout
this repo, edit a "vars" file, call "deploy", and have your own instances
running - but this is a bit tricky.

# How does it work

The general principle how the "t_server" testbed works is as follows:

## Virtual machines

There are 3 VMs involved:

1. The "server VM" which builds openvpn, and then starts server instances

1. The "anchor VM" which has one or more long-running openvpn processes
  that connect to the "server VM".  The "anchor VM" serves as a ping
  target, to verify that "client A" can ping "client B".  Also, the
  "anchor VM" typically has multiple extra IP addresses configured on
  its loopback interfaces, so "client -> ping -> iroute(!) -> anchor"
  can test iroute behaviour.

1. The "client VM" which has a number of precompiled OpenVPN binaries
    - depending on what the test should do, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7
      and git master clients, some with a very small set of tests
      ("connect, ping, verify 2.2<->master compatibility, hang up"), some
      with a very long and very detailed list.

## Master script

A master script (t_server.sh) runs this all, out of a daily cron job or on
demand if needed. The actions it takes are the following:

1. The script runs "git pull --rebase" in the "t_server.git/" directory,
   to update to the most recent commit in there - this can be a private
   repo for testing or public, the script does not care.

   (If you have locally applied patches, the script intentionally keeps them,
   so "gerrit work in progress" patches can be cherrypicked and tested)

1. The script then runs "autoreconf -vif" and "configure"
    * configure sets different options depending on weekday, like
      "build with openssl", "mbedtls", "small" - this mostly makes sense
      for the daily runs ("if we break mbedtls, we'll know a few days
      later")

1. Then "make", "make test" with a fairly large "t_client.rc" test set
  (so before we test server functionality, we should be sure that the
  binary just built at least behaves correctly as client)
    * the t_client.rc packed here will need adjustment for every testbed
      of course (certificates, IP addresses to be expected)

1. Results are printed to stdout in a relatively compact format, so 
   "cron job output" is meaningful

1. After building and testing, the resulting src/openvpn/openvpn binary
   is copied to the "the server instances live here" directory
   (/root/t_server/bin/).

1. The server instances running are stopped and restarted by calling
  sudo /root/t_server/stop, sleep, sudo /root/t_server/start

1. The "start" and "stop" script have a list in the scripts of subdirectories
  to process, and will run (relative to /root/t_server/)

     `./bin/openvpn --cd $subdirectory --config server.conf`

1. The script will then delay (by calling "oping -c10 $list_of_ips") a bit
  to give the "anchor VM" time to reconnect.  Pinging anchor IPs will also
  make it visible in the log if a problem happened here.

1. Finally, run "run_t_clients.sh"

    * This script will now shell out to the "client VM" and run multiple
      sets of "t_client.rc" tests, with different OpenVPN binaries (those
      need to be present)

    * The expected file/directory layout on the "client VM" is

        * **~/bin/t_client.sh:** modified t_client.sh from the Distro, which
                                 can handle "I expect this test to FAIL"
                                 (to test backend success/failure stuff)
        * **~/bin/openvpn.<branch>:** openvpn.22, .23, .24, etc
        * **~/t_client.<branch>/t_client.rc:** test set for the relative branches
        * **~/.ssh/authorized_keys:** give ssh access to the "server VM"

# What is in here

In here you can find a number of subdirectories with files from various
existing server instances.

## original

This directory contains the "original" t_server instance, running on a gentoo
system, focusing on "testing everything" - so the server instances have scripts
and plugins that are excercised from the t_client instances, and t_client
instances to test 2.2 to 2.6/master compatibility.

## ubuntu2004

This is "the linux DCO" t_server instance, which mostly tests "the kernel
forwarding side" - so more packet tests, less (or no) backend scripts, plugins,
etc. t_server.sh will build and run the client tests twice, once with
"configure --disable-dco" and once with DCO.

## fbsd14

This is "the FreeBSD DCO" t_server instance, very similar to "the Linux DCO"
instance (but using different IP addresses for everything, so it's easier to
see which instance a given client is talking to)

# Setup

(this section needs to be written)
