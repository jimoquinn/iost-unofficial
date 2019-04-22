#!/bin/bash 

# we need two functions
# - one to start the iserver
# - one to stop teh iserver



readonly SERVER_LOG="/tmp/iserver.$$.log"
readonly SERVER_ERR_LOG="/tmp/iserver.err.$$.log"
export IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"

. ~/.iost_env


#
#  iost_run() -  simply start the iserver
#
iost_run () {
  cd $IOST_ROOT
  nohup iserver -f config/iserver.yml 2>$SERVER_ERR_LOG >$SERVER_LOG&
  sleep 5
}

#
#  iost_stop() -  simply stop the iserver
#
iost_stop () {
  # check for a running iserver
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo "  ---> msg: iServer not running, continuing..."   | tee -a $SERVER_LOG
  else
    kill -15 $tpid  >> $SERVER_LOG 2>&1
    sleep 5
  fi
}


#
#  iost_start_iserver() -  simply start iserver
#
iost_start_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo "  ---> msg: iServer not running, now starting" 
    iost_run
  else
    echo "  ---> msg: iServer running as pid [$tpid], no need to start "
  fi
}


#
#  iost_stop_iserver() - gracefully shutdown iServer
#
iost_stop_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo "  ---> msg: iServer not running, continuing" | tee -a $SERVER_LOG
  else
    echo "  ---> msg: iServer running as pid [$tpid], now stopping"
    iost_stop
    echo "  ---> msg: iServer stopped, continuing " | tee -a $SERVER_LOG
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

  if (( $? == 1 )); then
    #echo "not running - not found tpid: $tpid";
    return 1
  else
    #echo "running - found tpid: $tpid";
    return 0
  fi
}


#
#  iost_restart_iserver()
#  - if already running, stop then start or return
#  - if not running, then start
#  -
iost_restart_iserver () {

  local tPID

  # 0=running, 1=not running
  if iost_check_iserver; then
    # tpid - this is a global variable set in iost_check_iserver()
    echo "  ---> msg: iServer running at pid [$tpid], now stopping"  | tee -a $SERVER_LOG
    iost_stop
    echo "  ---> msg: iServer starting"
    iost_run
  else
    echo "  ---> msg: iServer starting" 
    iost_run
    #tPID=$(iost_start_iserver)
    #read -p "  ---> msg: iServer log is located: $SERVER_LOG, hit any key to continue"
  fi

}

iost_start_iserver
iost_restart_iserver
iost_stop_iserver
