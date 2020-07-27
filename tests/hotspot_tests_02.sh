#!/bin/bash
#
# hotspot test suite - all tests to be peformed from the CLI 
# of the WLAN Pi whenswitched out of hotspot mode
#
#

##########################
# User configurable vars
##########################
MODULE=hotspot
VERSION=1.0
COMMENTS="hotspot test suite to verify files & processes when switched back to classic mode"
SCRIPT_NAME=$(basename $0)

# Tests log file
LOG_FILE="${SCRIPT_NAME}_results.log"
# WLAN Pi status file (hotspot, wiperf etc...)
STATUS_FILE="/etc/wlanpi-state"
# SSID broadcast by hotspot
SSID=wlanpi_hotspot


###########################
# script global vars
###########################
# initialize tests passed counter
tests_passed=0
# initialize tests failed counter
tests_failed=0

################
# root check
################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

##############################################
# Helper functions - see docs at end of file
##############################################

summary () {
  tests_completed=$((tests_passed + tests_failed))
  echo ""
  echo "-----------------------------------"
  echo " Total tests: $tests_completed"
  echo " Number tests passed: $tests_passed"
  echo " Number tests failed:  $tests_failed"
  echo "-----------------------------------"
  echo ""
}

inc_passed ()     { tests_passed=$((tests_passed + 1));  }
inc_failed ()     { tests_failed=$((tests_failed + 1));  }

info ()    { echo -n "(info) Test: $1" | tee -a $LOG_FILE;  }
info_n ()  { echo "(info) Test: $1" | tee -a $LOG_FILE;  }
comment () { echo $1 | tee -a $LOG_FILE; }

pass ()    { inc_passed; echo " $1  (pass)" | tee -a $LOG_FILE; }
fail ()    { inc_failed; echo " $1  (fail) <--- !!!!!!" | tee -a $LOG_FILE; }

check ()     { if [[ $1 ]];   then pass; else fail; fi; }
check_not () { if [[ ! $1 ]]; then pass; else fail; fi; }

file_exists ()    { info "Checking file exists: $1"; if [[ -e $1 ]]; then pass; else fail; fi; }
dir_exists ()     { info "Checking directory exists: $1"; if [[ -d $1 ]]; then pass; else fail; fi; }
symlink_exists () { info "Checking symlink exists: $1"; if [[ -L $1 ]]; then pass; else fail; fi; }
symlink_not () { info "Checking file is not symlink: $1"; if [[ ! -L $1 ]]; then pass; else fail; fi;  }
check_process ()  { info "Checking process running: $1"; if [[ `pgrep $1` ]]; then pass; else fail; fi; }
check_systemctl () { info "Checking systemctl running: $1"; if [[ `systemctl status $1 | grep 'active (running)'` ]]; then pass; else fail; fi; }

########################################
# Test rig overview
########################################
echo "\

=======================================================
Test rig description:

  1. WLAN Pi running image to be tested
  2. Supported wireless NIC card on one of USB ports
  3. WLAN Pi is switched in to classic mode after hotspot tests
  4. Power up WLAN Pi via USB/OTG connection
  5. Run tests by opening SSH session to 169.254.42.1 
  6. Run this test script:
      /etc/wlanpihotspot/tests/hotspot_tests_02.sh

=======================================================" | tee $LOG_FILE

########################################
# Test suite
########################################

run_tests () {

  comment ""
  comment "###########################################"
  comment "  Running $MODULE test suite"
  comment "###########################################"
  comment ""

  # check what state the WLAN Pi is in
  info "Checking current mode is classic"
  check `cat $STATUS_FILE | grep 'classic'`

  # check we have directories expected
  dir_exists "/etc/wlanpihotspot"

  # check various files exist after switch back
  file_exists "/etc/hostapd.conf"
  file_exists "/etc/default/isc-dhcp-server"
  file_exists "/etc/default/ufw"
  file_exists "/etc/dhcp/dhcpd.conf"
  file_exists "/etc/network/interfaces"
  file_exists "/etc/sysctl.conf"
  file_exists "/etc/ufw/before.rules"
  file_exists "/usr/bin/hotspot_switcher"

  # check files no longer symbolic links
  symlink_not "/etc/network/interfaces"
  symlink_not "/etc/default/isc-dhcp-server"
  symlink_not "/etc/dhcp/dhcpd.conf"
  symlink_not "/etc/hostapd.conf"
  symlink_not "/etc/sysctl.conf"
  symlink_not "/etc/default/ufw"
  symlink_not "/etc/ufw/before.rules"

  # check wlan port is no longer Mode:Master
  info "Checking wlan adapter no longer master mode"
  check_not `iwconfig wlan0 | grep 'Mode:Master'`

  # check wlan0 no longer running with default IP
  wlan0_ip=192.168.88.1
  info "Checking wlan0 no longer using defaut IP (${wlan0_ip})"
  check_not `ifconfig wlan0 | grep $wlan0_ip`

  # check forwarding no longer enabled
  info "Checking firewall forwarding no longer enabled"
  check_not `cat /etc/default/ufw | grep 'DEFAULT_FORWARD_POLICY="ACCEPT"'`

  # check NAT not enabled - check for line from NAT config
  info "Checking firewall NAT not enabled"
  check_not `cat /etc/ufw/before.rules | grep 'POSTROUTING -s 192.168.88.0/24 -o eth0 -j MASQUERADE'`

  # Print test run results summary
  summary

  comment ""
  comment "###########################################"
  comment "  End of $MODULE test suite"
  comment "###########################################"
  comment ""

}

########################################
# main
########################################

case "$1" in
  -v)
        echo ""
        echo "Test script version: $VERSION"
        echo $COMMENTS
        echo ""
        exit 0
        ;;
  -h)
        echo "Usage: $SCRIPT_NAME [ -h | -v ]"
        echo ""
        echo "  $SCRIPT_NAME -v : script version"
        echo "  $SCRIPT_NAME -h : script help"
        echo "  $SCRIPT_NAME    : run test suite"
        echo ""
        exit 0
        ;;
  *)
        run_tests
        exit $tests_failed
        ;;
esac

# should never reach here, but just in case....
exit 1

<< 'HOWTO'

#################################################################################################################

Test Utility Documentation
--------------------------

 This script uses a set of useful utilities to simplify running a series of 
 tests from this bash script. The syntax of the utilities is shown below:

 inc_passed: increment the test-passed counter (global var 'tests_passed')
 inc_failed: increment the test-failed counter (global var 'tests_failed')
 info: pre-prend the text in $1 with "info" and send to stdout & the log file (no CR)
 info_n: pre-prend the text in $1 with "info" and send to stdout & the log file (inc CR after msg)
 pass: write a "pass" msg to stdout & the log file, with optional additional msg in $1 (var passed to function)
 fail: write a "fail" msg to stdout & the log file, with optional additional msg in $1 (var passed to function)
 comment: output raw text supplied in $1 to std & log file

 check: call pass() if condition passed is true (can inc option msg via $1), otherwise fail()
 check_not: call pass() if condition passed is false (can inc option msg via $1), otherwise fail()

 file_exists: call pass() if file name passed via $1 exists, else call fail()
 dir_exists: call pass() if dir name passed via $1 exists, else call fail()
 symlink_exists: call pass() if file name passed via $1 is a symlink, else call fail()
 symlink_not: call pass() if file name passed via $1 is not symlink, else call fail()
 check_process: call pass() if process name passed via $1 is running, else call fail()
 check_systemctl: call pass() if service name passed via $1 is running, else call fail()

#################################################################################################################
HOWTO
