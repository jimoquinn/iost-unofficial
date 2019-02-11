#!/bin/bash



#
#  iost_check_iserver() - confirm that local iServer is running
#  usage: if iost_check_server; then; echo "running"; fi
#  >=1 - successful, the iserver is running
#   =0 - not successful, the iserver is not running
iost_check_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);

  if (( $? >= 1 )); then
    echo "not found: $tpid";
    echo 0
  else
    echo "found: $tpid";
    echo $tpid
  fi
}



rc=$(iost_check_iserver)

echo "rc: $rc"
