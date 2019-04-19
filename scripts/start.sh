#!/bin/bash -x

# we need two functions
# - one to start the iserver
# - one to stop teh iserver


readonly SERVER_LOG="/tmp/iserver.$$.log"
readonly SERVER_ERR_LOG="/tmp/iserver.err.$$.log"
IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"



#
#  iost_run() -  simply start the iserver
#
iost_run () {
    cd $IOST_ROOT
    nohup iserver -f config/iserver.yaml 2>$SERVER_ERR_LOG >$SERVER_LOG&
}

#
#  iost_start_iserver() -  simply start the iserver
#
iost_start_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    read -p "  ---> msg: iServer not running, hit any key to contine " tCONT
    iost_run
  else
    echo "  ---> msg: iServer running as pid [$tpid] and now stopping"
    kill -15 $tpid 
    sleep 5
    read -p "  ---> msg: iServer stopped, now starting" tCONT
    iost_run
  fi
}


#
#  iost_stop_iserver() - gracefully shutdown iServer
#
iost_stop_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    read -p "  ---> msg: iServer not running, hit any key to contine " tCONT
    iost_run
  else
    echo "  ---> msg: iServer running as pid [$tpid] and now stopping"
    kill -15 $tpid
    read -p "  ---> msg: iServer stopped, hit any key to contine " tCONT
    iost_run
  fi

}



#
#  iost_check_iserver() - confirm that local iServer is running
#  usage: if iost_check_server; then; echo "running"; fi
#  >=1 - successful, the iserver is running
#   =0 - not successful, the iserver is not running
iost_check_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);

  #echo "tpid: $tpid";

  if (( $? == 1 )); then
    #echo "not found tpid: $tpid";
    return 1
  else
    #echo "found tpid: $tpid";
    return 0
  fi
}

#
#  iost_run_iserver()
#  - if already running, stop then start or return
#  - if not running, then start
#  -
iost_run_iserver () {

  local tPID

  # 0=running, 1=not running
  if iost_check_iserver; then
    # tpid - this is a global variable set in iost_check_iserver()
    read -p "  ---> msg: iServer already running pid [$tpid], want to restart? (Y/n): " rSTRT
    if [ ! -z "$rSTRT" ]; then
      if [ $rSTRT == "y" ] || [ $rSTRT == 'Y' ] || [ $rSTRT == '' ]; then
        echo "  ---> msg: stopping iServer"
        iost_stop_iserver
        echo "  ---> msg: starting iServer"
        iost_start_iserver
      else
        read -p "  ---> msg: not restarting iServer, hit any key to contine " tCONT
        iost_run
      fi
    fi
  else
    tPID=$(iost_start_iserver)
    read -p "  ---> msg: server log is located: $SERVER_LOG, hit any key to continue"
  fi

}

iost_run_iserver
