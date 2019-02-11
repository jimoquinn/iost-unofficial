#!/bin/bash  

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
#                IOST "One Click" Install 
#         Baremetal Development Environment
#         **  For Greenfield Installs Only  **
#  
#  Sun Feb 10 16:32:15 CST 2019
#
#  Objective:  to provide a single script that will install
#  all the necessary dependecies and IOST code required to be
#  productive in less than 15 minutes.  
#
#  This is a greenfield install only, so only use on a fresh 
#  install of Linux.  It will check for previous install attemps, 
#  remove all the prevous installed dependicies, and start the 
#  install again.  Consider yourself warned.
#
#  We'll install the following: 
#
#  - updates and patches for your distro
#  - apt-transport-https ca-certificates 
#  - software-properties-common 
#  - build-essential curl git git-lfs 
#  - libgflags-dev libsnappy-dev zlib1g-dev 
#  - libbz2-dev liblz4-dev libzstd-dev   
#  - nvm npm node
#  - Go Lang
#
#  IOST from github.com/iost-official/go-iost
#  - iWallet - the wallet for IOST
#  - iServer - the node/servinode daemon
#  - v8vm    - the virtual machine
#  - scaf    - dApp development tool
#
#  Report bugs here:
#  -  https://github.com/jimoquinn/iost-unofficial
#
#  You can contact me here:
#  -  jim.oquinn@gmail.com
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# package.io not supported on cosmic yet

readonly UBUNTU_MANDATORY=('16.04' '16.10' '18.04');  # 'xenial' 'yakkety' 'bionic'
readonly CENTOS_MANDATORY=('centos7');
readonly DEBIAN_MANDATORY=('stretch');
readonly MACOS_MANDATORY=('Darwin', 'Hitchens');

readonly GOLANG_MANDATORY="1.11.3"
readonly NODE_MANDATORY="v10.14.2"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.34.0"
readonly DOCKER_MANDATORY="v18.06.0-ce"

# misc unused flags - use later for automatic install
readonly IOST_MANDATORY=""
readonly FOR_VAGRANT="1"	
readonly IOST_CLEAN_INSTALL="1"

# install and blockchain logs
readonly LOG="/tmp/bootstrap.sh.$$.log"
readonly ISERVER_LOG="/tmp/iserver.$$.log"
readonly ITEST_LOG="/tmp/itest.$$.log"


# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#  NO NEED TO MODIFY BELOW THIS LINE UNLESS THE BUILD IS TOTALLY BROKEN
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#
# list of functions
# 
# iost_warning_reqirements()
# iost_sudo_confirm()
# iost_install_packages()
# iost_install_nvm_node_npm()
# iost_install_docker()
# iost_install_golang()

#
#
#
exists() {

  test -x $(command -v $1)
  if (( $? >= 1 )); then
    echo "---> err: command [$1] does not exist"
    return $?
  fi
}


#
# TODO: __error_handler()
#
__error_handler() {
  echo "Error occurred in script at line: ${1}."
  echo "Line exited with status: ${2}"
}

trap '_error_handler ${LINENO} $?' ERR

#set -o errexit
#set -o errtrace
#set -o errpipe
#set -o nounset


#
# 
#
iost_install_init () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - pre-init      -------------------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_init () " | tee -a $LOG

  # 1st - confirm that we are not running under root
  if [[ $(whoami) == "root" ]]; then
      echo 'WARNING:  You should not run this as the "root" user. Modify the sudoers with visudo.'
      echo 'Example, once in the editor, add the following to the bottom of the file.  Be sure '
      echo 'to replace NON-ROOT_USER with your actual user id (run "whoami" at the command prompt).'
      echo ''
      echo 'NON-ROOT-USER ALL=(ALL:ALL) ALL'
      echo ''
      exit 99
  fi

  # 2nd - test if we can sudo 
  echo "---> msg: performing [sudo] check"
  sudo $(pwd)/data/exit.sh
  if (( $? >= 1 )); then
    echo "---> err: cannot [sudo]"
    exit; 98
  fi


  # 3rd - for installed apps
  # check for: 
  # - Ubuntu: 16.04, 16.10, 18.04
  # - Debian: 9.1-6, 10
  # - CentOS: 7.0-6
  # -  MacOS: 14.0.0-2
  # -    Win: 10, Server 2016-2019

  if [ -e /etc/os-release ]; then
    # Access $ID, $VERSION_ID and $PRETTY_NAME
    source /etc/os-release
    echo "---> msg: found distribution [$ID], release [$VERSION_ID], and pretty name [$PRETTY_NAME]"
    DIST=$ID
  else
    ID=unknown
    VERSION_ID=unknown
    PRETTY_NAME="Unknown distribution and release"
    echo "---> msg: /etc/os-release configuration not found, distribution unknown" 
    if [ -z "$DIST" -o -z "$CODE" ]; then
      echo "---> err: This is an unsupported distribution and/or version, exiting" 
      exit 98
    fi
  fi

  # pick the installer based off distribution
  if [ -n "$DIST" ]; then
    DIST=${DIST,,}
    echo "---> msg: determining package installer for [$PRETTY_NAME]"
      case "$DIST" in

        centos|rhel)
          pkg_installer="/usr/bin/yum "
          pkg_purge=" -e "
          pkg_yes=" -y "
          git_lfs="sudo $pkg_installer install epel-release"
          dev_tools="sudo $pkg_installer groupinstall \"Development Tools]""
          #dev_tools="sudo $pkg_installer groupinstall "\"Development Tools\""
          echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          ;;

        debian)
          # check version is supported
          if echo ${DEBIAN_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_installer="/usr/bin/apt-get -y"
            # setup packages-debian.txt
            echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo "---> err: [$VERSION_ID] [${PRETTY_NAME}] is not supported, view $LOG"
            exit 77
          fi
          ;;
        ubuntu)
            if echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_installer="/usr/bin/apt-get -y "
            pkg_purge=" purge "
            pkg_yes=" -y "
            git_lfs="curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
            dev_tools="$pkg_installer software-properties-common  build-essential"
            # setup packages-ubuntu.txt
            echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo "---> err: [${PRETTY_NAME}] is not supported, view $LOG"
            exit 76
          fi
          ;;

        *)
          echo "---> err: the package installer for [$PRETTY_INSTALLER] is unsupported, view $LOG"
          exit 95
          ;;

        esac
    fi


  #
  #  check that git is installed
  #

  #command -v git >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
  if exists git; then
    echo "---> run: $pkg_installer install git"
    sudo $pkg_installer install git  >> $LOG 2>&1
  else
    mygit=$(git --version 2>/dev/null)
    echo "---> msg: $mygit already installed"
  fi

  #
  # TODO: check for installed apps
  # 4th - for installed apps
  # check for: 
  # -  apt: git, git-lfs, software-properties-common, build-essential, curl,
  #    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev 
  # -  nvm, node, npm, yarn, docker, golang, 
  # -  IOST: iwallet, iserver, scaf, 
  #
  if [ -f "$HOME/.iost_env" ]; then
    echo "---> irk: previous install found!"
    read -p "---> irk: should I remove this previous version? (Y/n): " rCONT

    if [ ! -z "$rCONT" ]; then
      if [ $rCONT == "n" ] || [ $rCONT == 'N' ] || [ $rCONT == '' ]; then
        echo "---> msg: continuing without removing previous version";
      else
        echo "---> msg: will REMOVE PREVIOUS version";
        iost_install_rmfr
      fi
    fi
  fi

  echo "---> msg: done: iost_install_init () " | tee -a $LOG
	
}


#
# iost_install_rmfr() - remove previous installation (likely needs more work)
#
iost_install_rmfr () {
  # remove:
  # -  apt: git, git-lfs, software-properties-common, build-essential, curl,
  #    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev 
  #    docker
  # -  nvm, node, npm, yarn, golang, 
  # -  IOST: iwallet, iserver, scaf, 

  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - removing previous install  ------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_rmfr () " | tee -a $LOG

  echo "---> run: sudo systemctl disable docker-ce"
  sudo systemctl disable docker >> $LOG 2>&1
  echo "---> run: sudo systemctl stop docker-ce"
  sudo systemctl stop docker >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer purge docker-ce libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev  "
  sudo $pkg_installer purge docker-ce libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev    >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer purge git git-lfs software-properties-common  build-essential curl  " 
  sudo $pkg_installer purge git git-lfs software-properties-common  build-essential curl    >> $LOG 2>&1

  pkg_installert=$pkg_installer
  pkg_installer="$pkg_installer purge "
  echo "---> run: sudo $dev_tools" 
  sudo $dev_tools                                  >> $LOG 2>&1
  pkg_installer=$pkg_installert

  echo "---> run: sudo $pkg_installer purge install apt-transport-https  "
  sudo $pkg_installer purge apt-transport-https    >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer autoremove  " 
  sudo $pkg_installer autoremove                   >> $LOG 2>&1

  if [ -f "$HOME/.iost_env" ]; then
    echo "---> run: rm -fr $HOME/.iost_env"
    rm -fr $HOME/.iost_env
  fi

  if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
    echo "---> run: sudo rm -fr /etc/apt/sources.list.d/docker.list" 
    sudo rm -fr /etc/apt/sources.list.d/docker.list
  fi

  unset NVM_DIR
  if [ -d "$HOME/.nvm" ]; then
    echo "---> run: rm -fr $HOME/.nvm" 
    rm -fr $HOME/.nvm
  fi

  echo "---> msg: done: iost_install_rmfr () " | tee -a $LOG

}


#
#  TODO: iost_install_end () 
#
#  - prompt to launch iwallet
#  - prompt to launch iserver
#  - prompt to start dApp dev environment
#
iost_install_end () {
  echo "---> msg: done: iost_install_end () "
  echo "---> msg: done: iost_install_end () "
}


#
#  iost_warning_requirements () - 
#
iost_warning_requirements () {
  
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - warning and requirements   ------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "Please read carefully as these are hard requirements:"; echo ""
  echo "  1.  This is for a greenfield install, do not install on a configured system."
  echo "  2.  Do not run as the root user.  Run under a user that can sudo to root (man visudo)."
  echo "  3.  The install log file will be located:  $LOG "
  echo ""; echo "";


  echo "This script will install the following:"; echo ""
  echo "  -  Security updates and patches for $PRETTY_NAME"
  echo "  -  nvm version $NVM_MANDATORY"
  echo "  -  node version $NODE_MANDATORY"
  echo "  -  npm version $NPM_MANDATORY"
  echo "  -  nvm version $NVM_MANDATORY"
  echo "  -  Go Lang verson $GOLANG_MANDATORY"
  #echo "  -  docker version $DOCKER_MANDATORY"
  #echo "  -  Many packages; software-properties-common, build-essential, curl, git, git-lfs, and more"
  echo ''

  read -p "Continue?  (Y/n): " CONT

  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ] || [ $CONT == '' ]; then
      echo ""; echo ""
      echo "Best if you do not install unless you meet the above requirements."
      echo "We know you don't give up that easy, so you will be back."
      echo ""; 
      echo ""
      exit 99
    fi
  fi
}


#
#  iost_install_packages () - 
#
iost_install_packages () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#------------------     IOST Install - installing packages   --------------=#' 
  echo '#=-------------------------------------------------------------------------=#'

  echo "---> msg: start: iost_install_packages()" | tee -a $LOG

  #$sec_updt=$($pkg_installer list --upgradable | grep security | wc -l)
  #$reg_updt=$($pkg_installer list --upgradable | wc -l)

  echo "---> run: sudo $pkg_installer install apt-transport-https ca-certificates "
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $LOG 2>&1

  #echo "---> msg: $sec_updt security udpates and $reg_updt regular updates needed"
  #if (( $reg_updt >= 25 )); then
  #  echo "---> msg: NOTE: given the large number if updagtes, this may take a while"
  #fi


  echo "---> run: sudo $pkg_installer update"
  sudo $pkg_installer update                               >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer upgrade "
  sudo $pkg_installer upgrade                              >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer install software-properties-common "
  sudo $pkg_installer install software-properties-common   >> $LOG 2>&1

  #echo "---> run: sudo add-apt-repository ppa:git-core/ppa "
  #sudo add-apt-repository ppa:git-core/ppa  -y            >> $LOG 2>&1

  echo "---> run: sudo $dev_tools"
  sudo $dev_tools                                          >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer install build-essential curl git "
  sudo $pkg_installer install build-essential curl git     >> $LOG 2>&1

  # already handeled 
  #if ! [ -x "$(command -v git)" ]; then
  #  echo '---> err: git is not installed and executable'; 
  #  exit 98
  #else
  #  echo -n '---> msg: git installed version '
  #  git --version | cut -f3 -d' ' 2>/dev/null
  #fi


  # install Large File Support for git
  echo "---> run: sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
  sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer install git-lfs"
  sudo $pkg_installer install git-lfs >> $LOG 2>&1

  echo "---> run: git lfs install"
  git lfs install >> $LOG 2>&1
  echo "---> msg: done: iost_install_packages()" | tee -a $LOG

}


#
#  iost_install_nvm_node_npm () - 
#
iost_install_nvm_node_npm () {

  local ERR=0

  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#=------------------   IOST Install - nvm, node, npm, & yarn  -------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_nvm_node_npm ()"  | tee -a $LOG
  cd $HOME
  echo "---> run: curl -s https://raw.githubusercontent.com/creationix/nvm/${NVM_MANDATORY}/install.sh | bash"   
  curl -s https://raw.githubusercontent.com/creationix/nvm/${NVM_MANDATORY}/install.sh | bash      >> $LOG 2>&1

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


  echo "export NVM_DIR=$HOME/.nvm"                                          >> $HOME/.iost_env
  echo "[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh""                   >> $HOME/.iost_env 
  echo "[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"" >> $HOME/.iost_env  

  echo "---> run: nvm install $NODE_MANDATORY "
  nvm install $NODE_MANDATORY   >> $LOG 2>&1

  echo "---> run: npm i yarn"
  npm i yarn  >> $LOG 2>&1

  echo -n '---> msg: nvm version '
  NVM_V=$(nvm --version 2>/dev/null)
  if [ -z $NVM_V ]; then
    echo ""; echo "---> msg: error: nvm install failed, check $LOG"
    ERR=1
  else
    echo "$NVM_V"
  fi

  echo -n '---> msg: npm version '
  NPM_V=$(npm --version 2>/dev/null)
  if [ -z $NPM_V ]; then
    echo ""; echo "---> msg: error: npm install failed, check $LOG"
    ERR=1
  else
    echo "$NPM_V"
  fi

  echo -n '---> msg: node version '
  NODE_V=$(node --version 2>/dev/null)
  if [ -z $NODE_V ]; then
    echo ""; echo "---> msg: error: node install failed, check $LOG"
    ERR=1
  else
    echo "$NODE_V"
  fi

  if (( $ERR == 1 )); then
    echo '---> err: one or more of the folloing failed to install: nvm, node, npm'
    exit 55
  fi

  echo "---> msg: nvm, node, and npm installed"
  echo "---> msg: done: iost_install_nvm_node_npm ()"  | tee -a $LOG
}



#
#  iost_install_docker () - 
#
iost_install_docker () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#=------------------   IOST Install - Installing Docker    ----------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_docker ()" | tee -a $LOG

  echo "---> run: sudo $pkg_installer install apt-transport-https ca-certificates  >> $LOG 2>&1"
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $LOG 2>&1

  echo "---> run: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> $LOG 2>&1

  echo "---> run: git_docker="$(packages/${DIST}_${VERSION_ID}.sh >> $LOG 2>&1)"";
  git_docker="$(packages/${DIST}_${VERSION_ID}.sh >> $LOG 2>&1)"

  #lsb=$(lsb_release -cs)
  #echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $lsb stable" | sudo tee /etc/apt/sources.list.d/docker.list  >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer update"
  sudo $pkg_installer update                >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer install docker-ce "
  sudo $pkg_installer install docker-ce     >> $LOG 2>&1

  # Add user account to the docker group
  echo "---> run: sudo usermod -aG docker $(whoami) "
  sudo usermod -aG docker $(whoami)         >> $LOG 2>&1

  echo "---> run: systemctl enable docker"
  sudo systemctl enable docker              >> $LOG 2>&1
  echo "---> run: systemctl run docker"
  sudo systemctl run docker                 >> $LOG 2>&1

  echo -n '---> msg: docker version '
  DOCKER_V=$(docker --version 2>/dev/null)
  if [ -z $DOCKER_V ]; then
    echo "---> msg: error: docker-ce install failed, check $LOG"
    ERR=1
  else
    echo "$DOCKER_V"
  fi

  echo "---> msg: done: iost_install_docker ()" | tee -a $LOG
}


#
#  iost_install_golang() - 
#
iost_install_golang () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#=------------------   IOST Install - Installing Golang    ----------------=#"
  echo "#=-------------------------------------------------------------------------=#"

  echo "---> msg: start: iost_install_golang ()" | tee -a $LOG
  IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"
  alias IOST="cd $IOST_ROOT"

  # check for logic that sources IOST env file
  CHK_SETUP=$(grep "IOST setup" $HOME/.bashrc > /dev/null >&1)  
  if [ -z "$CHK_SETUP" ]; then 
    echo "---> msg: did not find IOST setup in .bashrc, adding"
    echo "if [ -f "$HOME/.iost_env" ]; then" >> $HOME/.bashrc
    echo "  source $HOME/.iost_env"          >> $HOME/.bashrc
    echo "fi"                                >> $HOME/.bashrc
  else
    echo "---> msg: found IOST setup in [$HOME/.bashrc], will not add"
  fi

  echo ""                          >> $HOME/.iost_env
  echo "#"                         >> $HOME/.iost_env
  echo "# Start:  IOST setup"      >> $HOME/.iost_env
  echo "#"                         >> $HOME/.iost_env
  echo "export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost"                >> $HOME/.iost_env
  echo "alias IOST=\"cd $IOST_ROOT\""                                                  >> $HOME/.iost_env

  if [ -f "/tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz" ]; then
    echo "---> run: rm -fr /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz";
    rm -fr /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz                               >> $LOG 2>&1
  fi

  echo "---> run: cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz    >> $LOG 2>&1

  echo "---> run: sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz                 >> $LOG 2>&1

  echo "---> run: export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	               >> $LOG 2>&1
  echo "---> run: export GOPATH=$HOME/go" 			                       >> $LOG 2>&1

  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	                       >> $HOME/.iost_env
  echo "export GOPATH=$HOME/go" 			                               >> $HOME/.iost_env

  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  export GOPATH=$HOME/go
  source $HOME/.iost_env
  source $HOME/.bashrc

  echo "---> run: mkdir -p $GOPATH/src && cd $GOPATH/src"
  mkdir -p $GOPATH/src && cd $GOPATH/src

  echo -n '---> msg: go version '
  GO_V=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
  if [ -z $GO_V ]; then
    echo "---> msg: error: $GOLANG_MANDATORY install failed, check $LOG"
    ERR=1
    exit 50
  else
    echo "$GO_V"
  fi

  echo "---> msg: done: iost_install_golang ()" | tee -a $LOG
}

#
#  iost_check_iserver() - confirm that local iServer is running
#  usage: if iost_check_server; then; echo "running"; fi
#  >=1 - successful, the iserver is running
#   =0 - not successful, the iserver is not running
iost_check_iserver () {

  # check for a running iserver
  tpid=$(pidof iserver);

  echo "tpid: $tpid";

  if (( $? == 1 )); then
    echo "not found tpid: $tpid";
    echo 0
  else
    echo "found tpid: $tpid";
    echo $tpid
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
    read -p "  ---> msg: iServer already running pid [$tpid], want to restart? (Y/n): " rSTRT
    if [ ! -z "$rSTRT" ]; then
      if [ $rSTRT == "y" ] || [ $rSTRT == 'Y' ] || [ $rSTRT == '' ]; then
        iost_stop_iserver 
	iost_start_iserver
      else
        read -p "  ---> msg: not restarting iServer, hit any key to contine " tCONT
        iost_run
      fi
    fi
  else
    
    tPID=$(iost_start_iserver)
    
    read -p "  ---> msg: server log is located: $ISERVER_LOG, hit any key to continue"
  fi

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
    iserver -f config/iserver.yaml
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
#  iost_install_iost_core  () - install the IOST core code
#
iost_install_iost_core () {

  echo ''; echo ''
  
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=--------- IOST Install - install core                               -----=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> msg: start: iost_install_core ()" | tee -a $LOG


  echo "---> msg: setup the environment $HOME/.iost_env"
  source $HOME/.iost_env

  ###go get -d github.com/iost-official/go-iost
  ###cd github.com/iost-official/go-iost/

  echo "---> msg: env | grep GO"
  res=$(env | grep GO > /dev/null 2>&1)
  echo "---> msg: res [$res]"

  echo "---> msg: cd $GOPATH/src"
  cd $GOPATH/src
  echo "---> msg: go get -d github.com/iost-official/go-iost"
  go get -d github.com/iost-official/go-iost >> $LOG 2>&1

  echo "---> msg: use [cd $IOST_ROOT]"
  cd $IOST_ROOT

  echo "---> run: make build install"
  make build install >> $LOG 2>&1 

  echo "  ---> run: cd vm/v8vm/v8"
  cd vm/v8vm/v8
  echo "  ---> run: make clean js_bin vm install"
  #make clean js_bin vm install
  make clean js_bin vm install deploy >> $LOG 2>&1
  make deploy                         >> $LOG 2>&1

  read -p "---> msg: core IOST is installed, continue to the IOST Admin Menu? (Y/n): " tADM

  if [ ! -z "$tADM" ]; then
    if [ $tADM == "n" ] || [ $tADM == 'N' ] || [ $tADM == '' ]; then
        echo "---> msg: our work is done, now exiting"
	exit
    else
        iost_run
    fi
  fi


  # call the IOST Admin Menu
  #iost_run
  #echo "---> run: iserver -f ./config/iserver.yml"
  #nohup iserver -f ./config/iserver.yml  >> $LOG 2>&1 &
  #echo "---> msg: check nohup.out for iserver messages"
  #sleep 10

}


#
#  iost_install_iost_iwallet ()
#
iost_install_iost_iwallet () {

  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - build iwallet    --------------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> start: iost_install_iwallet ()" | tee -a $LOG

  #iost && cd iwallet/contract
  #npm install

  echo "---> end: iost_install_iwallet ()" | tee -a $LOG
}



#  
#  iost_install_iserver ()
#
iost_install_iserver () {
  echo ''; echo ''
  echo "  #=--------------------------------------------------=#"
  echo '  #=---------   IOST Install - iserver  --------------=#'
  echo "  #=--------------------------------------------------=#"

  echo "---> start: iost_install_iserver ()" | tee -a $LOG
  cd $IOST_ROOT
  echo "---> end: iost_install_iserver ()" | tee -a $LOG
}


#  
#  iost_install_dapp ()
#
iost_install_dapp () {
  echo "---> msg: go get -d github.com/iost-official/scaffold"
  go get -d github.com/iost-official/scaffold

  echo "---> msg: cd  $GOPATH/src/github.com/iost-official/scaffold"
  cd  $GOPATH/src/github.com/iost-official/scaffold

  echo "---> msg: npm install"
  npm install
  echo "---> msg: npm link"
  npm link

  echo "cd - && scaf --version"
  cd -
  scaf --version
}


#
#  iost_run_itests () - install the IOST core code
#
iost_run_itests () {

  echo ''; echo ''

  echo "  #=--------------------------------------------------=#"
  echo "  #=--------- IOST Install Administration Menu  ------=#"
  echo '  #=-- itest run a_case, t_case, c_case, cv_case  ----=#'
  echo "  #=--------------------------------------------------=#"
  

  cd $IOST_ROOT
  echo "cd $IOST_ROOT/test"
  cd test
  echo "  ---> run: itest run a_case";
  itest run a_case  >> $ITEST_LOG 2>&1

  echo "  ---> run: itest run t_case";
  itest run t_case  >> $ITEST_LOG 2>&1

  echo "  ---> run: itest run c_case";
  itest run c_case  >> $ITEST_LOG 2>&1

  echo "  ---> run: itest run cv_case";
  itest run cv_case >> $ITEST_LOG 2>&1

  read -p "  ---> hit any key to view the test logs" ttLOGS
  vi $ITEST_LOG

}



#
#  iost_run() - the main menu where we can control various
#  parts of the IOST ecosystem
#
iost_run () {
  source $HOME/.iost_env

  clear

  echo "  #=--------------------------------------------------=#"
  echo "  #=--------- IOST Install Administration Menu  ------=#"
  echo "  #=--------------------------------------------------=#"

  echo ""
  echo "    1.  Start local iServer           [working]"
  echo "    2.  Stop local iServer            [working]"
  echo "    3.  Run itest suite               [working]"
  echo "    4.  Connect to testnet            [n/a]"
  echo "    5.  Setup dApp development tools  [n/a]"
  echo "    6.  Run test dApp                 [n/a]"
  echo "    7.  Drop to a command prompt      [working]"
  echo "    9.  Quit"
  echo ""

  read -p "  Select a number: " iNUM

  case "$iNUM" in

    1) echo ""
       echo "  ---> msg: starting iServer"
       iost_run_iserver
       iost_run
    ;;

    2) echo ""
       echo "  ---> msg: stopping iServer"
       iost_stop_iserver
       iost_run
    ;;

    3) echo ""
       echo "  ---> msg: running iTests"
       iost_run_iserver
       iost_run_itests
       iost_run
    ;;

    4) echo ""
       #echo "  ---> msg: stopping iServer"
       read -p "  ---> msg: not implemented, hit any key to continue" tIN
       iost_run
    ;;

    5) echo ""
       read -p "  ---> msg: not implemented, hit any key to continue" tIN
       iost_run
    ;;

    6) echo ""
       read -p "  ---> msg: not implemented, hit any key to continue" tIN
       iost_run
    ;;

    7) echo "   ---> msg: opening a /bin/bash, type exit or CTRL-D to return"
       /bin/bash
       iost_run
    ;;

    9) echo ""
       echo "  ---> msg: exiting"
       exit
    ;;

  esac

}



#
#  iost_install_iost () - master setup func
#
iost_install_iost () {

  export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost
  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  export GOPATH=$HOME/go
  source $HOME/.iost_env
  source $HOME/.bashrc
  alias IOST="cd $IOST_ROOT"

  iost_install_iost_core
  #iost_install_iost_v8vm
  #iost_run_itests
  #iost_install_iost_iwallet
  #iost_install_iost_iserver
  #iost_install_iost_dapp

}


###
###   START - beginning of the install script
###

#set -e

iost_check_iserver
echo "rc: $?"

ls
echo "rc: $?"

iost_check_iserver
echo "rc: $?"

if [[ "$(iost_check_iserver)" ]]; then
  echo "running"
else
  echo "not running"
fi

#exit

iost_install_init
iost_warning_requirements
iost_install_packages
iost_install_nvm_node_npm
#iost_install_docker
iost_install_golang
iost_install_iost
iost_run


###
###   END - the end of the install script
###


