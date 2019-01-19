#!/bin/bash

# curl -o-  https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
# wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

#
# We need a shell, ability to download a shell script, and then execute
#
# 1.  All systems will have a shell
# 2.  Systems will have either wget or curl
# 3.  Minimum installs do not have git
#

set -e

readonly LOG="/tmp/init.sh.$$.log"

echo ""; echo ""
echo "#=-------------------------------------------------------------------------=#"
echo "#-----------------   IOST Install - pre-pre-init    -----------------------=#"
echo "#=-------------------------------------------------------------------------=#"
echo "---> msg: start: IOST pre-pre-installer"
echo "---> msg: a log of the install is here: $LOG"


#
#  find:  curl or wget
#
if loc=$(which wget 2>/dev/null); then

  downloader="wget -qO- "
  echo "---> msg: downloader: $cmd"

elif loc=$(which curl 2>/dev/null); then

  downloader="curl -s "
  echo "---> msg: downloader: $cmd"

else 
  
  echo "---> err: we need wget or curl for this script to work"
  exit 88;

fi


#
#  find:  yum or apt
#
if tpkg_install_t=$(which yum 2>/dev/null); then
  pkg_install="/usr/bin/yum -y "
  echo "---> msg: package installer: $pkg_install "
else
  pkg_install="/usr/bin/apt -y "
  echo "---> msg: package installer: $pkg_install "
fi	


#  find:  git or install
if tgit=(git --version); then
  echo "---> msg: found: $tgit"
else
  echo "---> run: $pkg_install install git"
  $pkg_install install git >> $LOG 2>&1 
fi

echo "---> msg: done: IOST pre-pre-installer"
echo "---> run: $downloader https://raw.githubusercontent.com/jimoquinn/iost-unofficial/master/bootstrap.sh | bash"
$downloader https://raw.githubusercontent.com/jimoquinn/iost-unofficial/master/bootstrap.sh >> $LOG  2>&1 

#ncmd="$cmd https://github.com/jimoquinn/iost-unofficial/bootstrap.sh | bash"

