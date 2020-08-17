#!/bin/bash 

# TODO
# - where did the go-sdk go?
# - 


# IOST release version: https://github.com/iost-official/go-iost
readonly IOST_RELEASE="3.1.1"

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
#          IOST Development Environment
#          Best for greenfield installs
#          Ubuntu in VM or OS container
#          Thu Aug 16 15:10:54 UTC 2020
#
#  This script will install all the tools necessary to develop
#  smart contracts in JavaScript or interface with the blockchain
#  with Go or JavaScript.  Works best in OS containers like LXD/LXC 
#  or a full VM, but is known to work in Docker as well.  Should 
#  install all the necessary dependencies and IOST code required 
#  to be productive in about 15 minutes.
#
#   IOST Installation:
#   Complete IOST blockchain installed locally with testnet and
#   blockchain explorer.  Both fully functional with no setup or
#   configuration.
#   -  IOST Blockchain Explorer
#   -  IOST Blockchain 
#
#   IOST Development Tools
#   -  local testnet node
#   -  iwallet
#   -  iserver
#   -  itest suite
#
#   IOST Software Development Kits
#   -  Go SDK 
#   -  JavaScript SDK
#   -  Java SDK
#   -  Python SDK
#   -  Ruby SDK
#
#  IOST Sample Code
#   -  JavaScript example blockchain code
#   -  JavaScript example dApp code
#   -  JavaScript iWallet Google Chrome extension
#   -  Go examples
#
#   Distros Supported:
#   -  Ubuntu 20.20 (Focal)
#   -  Ubuntu 18.04 (Bionic)
#
#   Dependencies Installed:
#   -  apt-transport-https ca-certificates
#   -  software-properties-common
#   -  build-essential curl git git-lfs
#   -  libgflags-dev libsnappy-dev zlib1g-dev
#   -  libbz2-dev liblz4-dev libzstd-dev
#   -  distro updates
#   -  nvm v0.34.0
#   -  npm v6.4.2
#   -  node v10.15.3
#   -  Go 1.13.1
#   -  Mongodb 4.4
#
#   Easy ASCII Admin Menu
#   -  IOST install
#   -  IOST removal
#   -  iServer start/stop/restart
#   -  run iTest suite
#   -  run JavaScript SDK test
#   -  run Blockchain test
#   -  run dapp smart contract
#   -  view install log#
#
#  Report bugs here:
#  -  https://github.com/jimoquinn/iost-unofficial
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Dependicies
readonly GOLANG_MANDATORY="1.13.1"
readonly NODE_MANDATORY="v10.15.3"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.34.0"
readonly DOCKER_MANDATORY="v18.06.0-ce"

# Supported UNIX distributions
readonly UBUNTU_MANDATORY=('16.04' '18.04' '18.10', '20.04');  	# Ubuntu 'xenial' 'yakkety' 'bionic'
readonly CENTOS_MANDATORY=('centos7' 'rhel');			# Redhat & CentOS
readonly DEBIAN_MANDATORY=('stretch');				# Debian Stretch
readonly MACOS_MANDATORY=('Darwin', 'Hitchens');        	# OSX 

# misc unused flags - use later for automatic install
readonly IOST_UNATTENDED=""					# unattended install
readonly IOST_CLEAN_INSTALL="0"					# unattended install, force remove of previous IOST install
readonly VAGRANT_USE=""						# use Vagrant box
readonly DOCKER_USE="0"    					# 1-yes | 0-no

# install and blockchain logs
readonly INSTALL_LOG="/tmp/bootstrap.sh.$$.log"			# stdout & stderr
readonly SERVER_LOG="/tmp/iserver.$$.log"			# stdout 
readonly SERVER_START_LOG="/tmp/iserver.start.$$.log"		# stdout 
readonly SERVER_ERR_LOG="/tmp/iserver.err.$$.log"		# stderr
readonly ITEST_LOG="/tmp/itest.$$.log"				# stdout & stderr
readonly IWALLET_LOG="/tmp/iwallet.$$.log"			# stdout & stderr

# variables
TOP_DIR="$HOME/iost-unofficial"
SCRIPT_DIR="$HOME/iost-unofficial/scripts"
IOST_DOCKER=""
IOST_BAREMETAL=""
RUNNING=""

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#  NO NEED TO MODIFY BELOW THIS LINE UNLESS THE BUILD IS TOTALLY BROKEN
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if [ -r libs/ui.sh ]; then 
  cmd=" ${CMD_COLOR}cmd:${OFF_COLOR}"
  run=" ${RUN_COLOR}run:${OFF_COLOR}"
  msg=" ${MSG_COLOR}msg:${OFF_COLOR}"
  irk=" ${ERROR_COLOR}irk:${OFF_COLOR}"
  err=" ${ERROR_COLOR}cmd:${OFF_COLOR}"
  source libs/ui.sh
fi

#
# IOST Install Functions 
# ---
# iost_install_iost_core()    - iwallet, iserver
# iost_install_itest()        - 
# iost_install_iost() 

#
# IOST Admin Functions 
# ---
# iost_start_iserver()	      - iServer start
# iost_restart_iserver()      - iServer restart
# iost_stop_iserver()         - iServer stop
# iost_check_iserver () 
# iost_run()                  - only starts iServer
# iost_stop()                 - only stops iServer
# iost_run_itests() 

#
# Install Functions for Dependencies
# ---
# iost_warning_reqirements()  - 
# iost_install_packages()     - 
# iost_install_nvm_node_npm() - 
# iost_install_docker()       -
# iost_install_golang()       -
# iost_baremetal_or_docker()  

#
# General Functions
# ---
# iost_install_init() 
# iost_install_rmfr() 
# iost_warning_requirements() 
# iost_main_menu()            - admin main menu
# iost_sudo_confirm()         - test for sudo
# iost_distro_detect()        - what distro?
# exists() 		      - check OS for command
#


#
# exists()  - does the command exist in the OS?
#
exists () {

  test -x $(command -v $1)
  if (( $? >= 1 )); then
    echo -e "---> $err command [$1] does not exist"
    return $?
  fi
}


#
# TODO: __error_handler()
#
__error_handler() {
  echo -e "Error occurred in script at line: ${1}."
  echo -e "Line exited with status: ${2}"
}

trap '_error_handler ${LINENO} $?' ERR


#
#  iost_distro_detect() - 
#
iost_distro_detect () {

  # - Ubuntu: 16.04, 18.04
  # - Debian: 9.1-6, 10
  # - CentOS: 7.0-6
  # - MacOS: 14.0.0-2
  # - Win: 10, Server 2016-2019

  if [ -e /etc/os-release ]; then
    # Access $ID, $VERSION_ID and $PRETTY_NAME
    source /etc/os-release
    echo -e "---> $msg found distribution [$ID], release [$VERSION_ID], and pretty name [$PRETTY_NAME]"
    DIST=$ID
  else
    ID=unknown
    VERSION_ID=unknown
    PRETTY_NAME="Unknown distribution and release"
    echo -e "---> $msg /etc/os-release configuration not found, distribution unknown" 
    if [ -z "$DIST" -o -z "$CODE" ]; then
      echo -e "---> $err This is an unsupported distribution and/or version, exiting" 
      exit 98
    fi
  fi

  # pick the installer based off distribution
  if [ -n "$DIST" ]; then
    DIST=${DIST,,}
    echo -e "---> $msg determining package installer for [$PRETTY_NAME]"
      case "$DIST" in

        centos|rhel)
          pkg_installer="/usr/bin/yum "
          pkg_purge=" -e "
          pkg_yes=" -y "
          git_lfs="sudo $pkg_installer install epel-release"
          dev_tools="sudo $pkg_installer groupinstall \"Development Tools]""
          #dev_tools="sudo $pkg_installer groupinstall "\"Development Tools\""
          #dev_tools_purge="sudo $pkg_installer groupinstall "\"Development Tools\""
          echo -e "---> $msg [$PRETTY_NAME] is supported and using [$pkg_installer]"
          ;;

        debian)
          # check version is supported
          if echo -e ${DEBIAN_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_installer="/usr/bin/apt-get -y "
            # setup packages-debian.txt
            echo -e "---> $msg [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo -e "---> $err [$VERSION_ID] [${PRETTY_NAME}] is not supported, view $INSTALL_LOG"
            exit 77
          fi
          ;;
        ubuntu)
            if echo -e ${UBUNTU_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_bare="/usr/bin/apt-get "
            pkg_installer="/usr/bin/apt-get -y "
            pkg_purge=" purge "
            pkg_yes=" -y "
            git_lfs="curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
            dev_tools="$pkg_installer software-properties-common  build-essential"
            dev_tools_purge="$pkg_installer  purge software-properties-common  build-essential"
            # setup packages-ubuntu.txt
            echo -e "---> $msg [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo -e "---> $err [${PRETTY_NAME}] is not supported, view $INSTALL_LOG"
            exit 76
          fi
          ;;

        *)
          echo -e "---> $err the package installer for [$PRETTY_INSTALLER] is unsupported, view $INSTALL_LOG"
          exit 95
          ;;

        esac
    fi

}


#
# 
#
iost_install_init () {
  clear
  #if [ -z $RUNNING ]; then
  #  
  #fi

  echo -e "$INSTALL_LOG" > /tmp/install.name.log
  echo -e ""; echo -e ""
  echo -e "$dg#=-------------------------------------------------------------------------=#$zz"
  echo -e "$dg#-----------------   IOST Install - pre-init      -------------------------=#$zz"
  echo -e "$dg#=-------------------------------------------------------------------------=#$zz"
  echo -e "---> $msg start: iost_install_init () " | tee -a $INSTALL_LOG

  # 1st - confirm that we are not running under root
  if [[ $(whoami) == "root" ]]; then
      echo -e "WARNING:  You should not run this as the "root" user. Modify the sudoers with visudo."
      echo -e "Example, once in the editor, add the following to the bottom of the file.  Be sure "
      echo -e "to replace NON-ROOT_USER with your actual user id (run "whoami" at the command prompt)."
      echo -e ""
      echo -e "NON-ROOT-USER ALL=(ALL:ALL) ALL"
      echo -e ""
      exit 99
  fi

  # 2nd - test if we can sudo 
  echo -e "---> $msg performing [sudo] check"
  sudo $(pwd)/exit.sh
  if (( $? >= 1 )); then
    echo -e "---> $err cannot [sudo]"
    exit 98
  fi


  #
  #  determine distro and set variables
  #
  iost_distro_detect

  #
  # check status of the distro's packages
  #
  echo -e "---> $run sudo $pkg_installer check"
  sudo $pkg_installer check 				  >> $INSTALL_LOG 2>&1
  if (( $? >= 1 )); then
    echo -e "---> $err [$pkg_installer check] failed, see $INSTALL_LOG"
    echo -e "";
    exit 79
  fi

  #
  #  check that git is installed
  #
  if exists git; then
    echo -e "---> $run $pkg_installer install git"
    sudo $pkg_installer install git  >> $INSTALL_LOG 2>&1
  else
    mygit=$(git --version 2>/dev/null)
    echo -e "---> $msg $mygit already installed"
  fi

  #
  #  check that wgit is installed
  #
  #command -v wgit >/dev/null 2>&1 || { echo -e >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
  if exists wget; then
    echo -e "---> $run $pkg_installer install wget"
    sudo $pkg_installer install wget >> $INSTALL_LOG 2>&1
  else
    mywget=$(wget --version | head -n1 2>/dev/null)
    echo -e "---> $msg $mywget already installed"
  fi


  #
  #  unset any variables
  #
  if [ ! -z $NVM_DIR ]; then
    unset NVM_DIR
  fi


  #
  # TODO: check for installed apps
  # 4th - for installed apps
  # check for: 
  # -  apt: git, git-lfs, software-properties-common, build-essential, curl,
  #    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev 
  # -  nvm, node, npm, yarn, docker, golang, 
  # -  IOST: iwallet, iserver
  #
  if [ -f "$HOME/.iost_env" ]; then
    echo -e "---> $irk previous IOST install found!"
    read -p "---> $irk should I remove this previous version? (Y/n): " rCONT

    if [ ! -z "$rCONT" ]; then
      if [ $rCONT == "n" ] || [ $rCONT == 'N' ] || [ $rCONT == '' ]; then
        echo -e "---> $msg continuing without removing previous version";
      else
        echo -e "---> $msg will REMOVE PREVIOUS version";
        iost_install_rmfr
      fi
    fi
  fi

  echo -e "---> $msg done: iost_install_init () " | tee -a $INSTALL_LOG
	
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

  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#-----------------   IOST Install - removing previous install  ------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "---> $msg start: iost_install_rmfr () " | tee -a $INSTALL_LOG
  echo -e "---> $msg view log file: $INSTALL_LOG"

  #
  #  saturate environment
  #
  if [ -r $HOME/.iost_env ]; then
    echo -e "---> $msg $HOME/.iost_env present, adding to environment..."                   	| tee -a $INSTALL_LOG
    source $HOME/.iost_env
  else 
    echo -e    "---> $msg $HOME/.iost_env NOT present..."                   			| tee -a $INSTALL_LOG
    echo -e    "---> $msg this may be a partial install or a green system..."                   	| tee -a $INSTALL_LOG
    read -p "---> $msg do you want to continue with the removal?  (Y/n): " rCONT

    if [ ! -z "$rCONT" ]; then
      if [ $rCONT == "n" ] || [ $rCONT == 'N' ] || [ $rCONT == '' ]; then
        echo -e "---> $msg not removing anything....";
	iost_main_menu
      else
        echo -e "---> $msg will what is left of the previous install";
      fi
    fi
  fi

  #
  #  determine distro and set variables
  #
  iost_distro_detect

  if [ $DOCKER_USE -eq '1' ]; then
    echo -e "---> $run sudo systemctl disable docker-ce"
    sudo systemctl disable docker >> $INSTALL_LOG 2>&1
    echo -e "---> $run sudo systemctl stop docker-ce"
    sudo systemctl stop docker >> $INSTALL_LOG 2>&1
    sudo $pkg_installer $pkg_purge docker-ce >> $INSTALL_LOG 2>&1

    if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
      echo -e "---> $run sudo rm -fr /etc/apt/sources.list.d/docker.list" 
      sudo rm -fr /etc/apt/sources.list.d/docker.list
    fi
  fi

  echo -e "---> $run sudo $pkg_installer $pkg_purge libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev  "
  sudo $pkg_installer $pkg_purge libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev    	>> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer $pkg_purge git git-lfs software-properties-common  build-essential curl  " 
  sudo $pkg_installer $pkg_purge git git-lfs software-properties-common  build-essential curl    		>> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $dev_tools_purge" 
  sudo $dev_tools_purge                           	>> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer $pkg_purge apt-transport-https  "
  sudo $pkg_installer $pkg_purge apt-transport-https    >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer autoremove  " 
  sudo $pkg_installer autoremove                   	>> $INSTALL_LOG 2>&1

  if [ -f "$HOME/.iost_env" ]; then
    echo -e "---> $run rm -fr $HOME/.iost_env"
    rm -fr "$HOME/.iost_env"
  else 
    echo -e "---> $msg [$HOME/.iost_env] not found so not removing..."
  fi

  unset NVM_DIR
  if [ -d "$HOME/.nvm" ]; then
    echo -e "---> $run rm -fr $HOME/.nvm" 
    rm -fr "$HOME/.nvm"
  else 
    echo -e "---> $msg [$HOME/.nvm] not found so not removing..."
  fi

  # remove IOST source
  if [ -d "$HOME/go/src/github.com/iost-official/go-iost" ]; then
    echo -e "---> $run rm -fr $HOME/go/src/github.com/iost-official/go-iost" 
    rm -fr "$HOME/go/src/github.com/iost-official/go-iost"
  else 
    echo -e "---> $msg [$HOME/go/src/github.com/iost-official/go-iost] not found so not removing..."
  fi

  # remove IOST Go SDK 
  if [ -d "$HOME/go/src/github.com/iost-official/go-sdk" ]; then
    echo -e "---> $run rm -fr $HOME/go/src/github.com/iost-official/go-sdk"
    rm -fr "$HOME/go/src/github.com/iost-official/go-sdk"
  else 
    echo -e "---> $msg [$HOME/go/src/github.com/iost-official/go-sdk] not found so not removing..."
  fi

  # remove IOST JavaScript SDK
  if [ -d "$TOP_DIR/iost.js" ]; then
    echo -e "---> $run rm -fr $TOP_DIR/iost.js"
    rm -fr "$TOP_DIR/iost.js"
  else 
    echo -e "---> $msg [$TOP_DIR/iost.js] not found so not removing..."
  fi

  echo -e "---> $msg done: iost_install_rmfr () " | tee -a $INSTALL_LOG

}


#
#  iost_warning_requirements () - 
#
iost_warning_requirements () {
  
  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#-----------------   IOST Install - warning and requirements   ------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"
  #echo -e "Please read carefully as these are hard requirements:"; echo -e ""
  #echo -e "  1.  Do not install on a configured system."
  #echo -e "  2.  Run as a user that can sudo to root (man visudo)."
  echo -e ""; echo -e "";

  echo -e "This script will install the following:"; echo -e ""
  echo -e "  -  updates for $PRETTY_NAME"
  echo -e "  -  nvm version $NVM_MANDATORY"
  echo -e "  -  node version $NODE_MANDATORY"
  echo -e "  -  npm version $NPM_MANDATORY"
  echo -e "  -  nvm version $NVM_MANDATORY"
  echo -e "  -  Go Lang verson $GOLANG_MANDATORY"

  if [ $DOCKER_USE -eq '1' ]; then
    echo -e "  -  docker version $DOCKER_MANDATORY"
  fi

  echo -e "  -  IOST release $IOST_RELEASE"
  echo -e ''
  echo -e "Install log is located:  $INSTALL_LOG "
  echo -e ''

  read -p "Continue?  (Y/n): " CONT

  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ] || [ $CONT == '' ]; then
      echo -e ""; echo -e ""
      exit 99
    fi
  fi
}


#
#  iost_install_packages () - 
#
iost_install_packages () {
  echo -e ''; echo -e ''
  echo -e '#=-------------------------------------------------------------------------=#'
  echo -e '#------------------     IOST Install - installing packages   --------------=#' 
  echo -e '#=-------------------------------------------------------------------------=#'

  echo -e "---> $msg start: iost_install_packages()" | tee -a $INSTALL_LOG

  # second, run update 
  echo -e "---> $run sudo $pkg_installer update"
  sudo $pkg_installer update                               >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer install apt-transport-https ca-certificates "
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $INSTALL_LOG 2>&1

  # 2019/04/18 - 18.04 cannot run unattended (grub and ??) 18.04
  echo -e "---> $run DEBIAN_FRONTEND=noninteractive sudo apt-get -qy -o \"APT::Periodic::Unattended-Upgrade "1" -o DPkg::options::=\"--force-confdef\" -o DPkg::options::=\"--force-confold\" upgrade"
  DEBIAN_FRONTEND=noninteractive sudo apt-get -qy -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade  >> $INSTALL_LOG 2>&1
  #echo -e "---> $run sudo $pkg_installer upgrade "
  #sudo $pkg_installer upgrade                              >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer install software-properties-common "
  sudo $pkg_installer install software-properties-common   >> $INSTALL_LOG 2>&1

  #echo -e "---> $run sudo add-apt-repository ppa:git-core/ppa "
  #sudo add-apt-repository ppa:git-core/ppa  -y            >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $dev_tools"
  sudo $dev_tools                                          >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer install build-essential curl git "
  sudo $pkg_installer install build-essential curl git     >> $INSTALL_LOG 2>&1

  # install Large File Support for git
  echo -e "---> $run sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
  sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer install git-lfs"
  sudo $pkg_installer install git-lfs >> $INSTALL_LOG 2>&1

  echo -e "---> $run git lfs install"
  git lfs install >> $INSTALL_LOG 2>&1
  echo -e "---> $msg done: iost_install_packages()" | tee -a $INSTALL_LOG

}


#
#  iost_install_nvm_node_npm () - 
#
iost_install_nvm_node_npm () {

  local ERR=0

  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#=------------------   IOST Install - nvm, node, npm, & yarn  -------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "---> $msg start: iost_install_nvm_node_npm ()"  | tee -a $INSTALL_LOG
  cd $HOME
  echo -e "---> $run curl -s https://raw.githubusercontent.com/creationix/nvm/${NVM_MANDATORY}/install.sh | bash"   
  curl -s https://raw.githubusercontent.com/creationix/nvm/${NVM_MANDATORY}/install.sh | bash      >> $INSTALL_LOG 2>&1

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


  echo -e "export NVM_DIR=$HOME/.nvm"                                          >> $HOME/.iost_env
  echo -e "[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh""                   >> $HOME/.iost_env 
  echo -e "[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"" >> $HOME/.iost_env  

  echo -e "---> $run nvm install $NODE_MANDATORY "
  nvm install $NODE_MANDATORY   >> $INSTALL_LOG 2>&1

  echo -e "---> $run npm i yarn"
  npm i yarn  >> $INSTALL_LOG 2>&1

  echo -e -n "---> $msg nvm version "
  NVM_V=$(nvm --version 2>/dev/null)
  if [ -z $NVM_V ]; then
    echo -e ""; echo -e "---> $msg error: nvm install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo -e "$NVM_V"
  fi

  echo -e -n "---> $msg npm version "
  NPM_V=$(npm --version 2>/dev/null)
  if [ -z $NPM_V ]; then
    echo -e ""; echo -e "---> $msg error: npm install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo -e "$NPM_V"
  fi

  echo -e -n "---> $msg node version "
  NODE_V=$(node --version 2>/dev/null)
  if [ -z $NODE_V ]; then
    echo -e ""; echo -e "---> $msg error: node install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo -e "$NODE_V"
  fi

  if (( $ERR == 1 )); then
    echo -e "---> $err one or more of the folloing failed to install: nvm, node, npm"
    exit 55
  fi

  echo -e "---> $msg nvm, node, and npm installed"
  echo -e "---> $msg done: iost_install_nvm_node_npm ()"  | tee -a $INSTALL_LOG
}



#
#  iost_install_docker () - 
#
iost_install_docker () {
  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#=------------------   IOST Install - Installing Docker    ----------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "---> $msg start: iost_install_docker ()" | tee -a $INSTALL_LOG

  echo -e "---> $run sudo $pkg_installer install apt-transport-https ca-certificates  >> $INSTALL_LOG 2>&1"
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $INSTALL_LOG 2>&1

  echo -e "---> $run curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> $INSTALL_LOG 2>&1

  echo -e "---> $run git_docker="$(packages/${DIST}_${VERSION_ID}.sh >> $INSTALL_LOG 2>&1)"";
  git_docker="$(packages/${DIST}_${VERSION_ID}.sh >> $INSTALL_LOG 2>&1)"

  #lsb=$(lsb_release -cs)
  #echo -e "deb [arch=amd64] https://download.docker.com/linux/ubuntu $lsb stable" | sudo tee /etc/apt/sources.list.d/docker.list  >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer update"
  sudo $pkg_installer update                >> $INSTALL_LOG 2>&1

  echo -e "---> $run sudo $pkg_installer install docker-ce "
  sudo $pkg_installer install docker-ce     >> $INSTALL_LOG 2>&1

  # Add user account to the docker group
  echo -e "---> $run sudo usermod -aG docker $(whoami) "
  sudo usermod -aG docker $(whoami)         >> $INSTALL_LOG 2>&1

  echo -e "---> $run systemctl enable docker"
  sudo systemctl enable docker              >> $INSTALL_LOG 2>&1
  echo -e "---> $run systemctl run docker"
  sudo systemctl run docker                 >> $INSTALL_LOG 2>&1

  echo -e -n '---> $msg docker version '
  DOCKER_V=$(docker --version 2>/dev/null)
  if [ -z $DOCKER_V ]; then
    echo -e "---> $msg error: docker-ce install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo -e "$DOCKER_V"
  fi

  echo -e "---> $msg done: iost_install_docker ()" | tee -a $INSTALL_LOG
}


#
#  iost_install_golang() - 
#
iost_install_golang () {
  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#=------------------   IOST Install - Installing Golang    ----------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"

  echo -e "---> $msg start: iost_install_golang ()" | tee -a $INSTALL_LOG
  export IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"
  alias IOST="cd $IOST_ROOT"

  # check for logic that sources IOST env file
  CHK_SETUP=$(grep "IOST setup" $HOME/.bashrc > /dev/null >&1)  
  if [ -z "$CHK_SETUP" ]; then 
    echo -e "---> $msg did not find IOST setup in .bashrc, adding"
    # insert a blank line b/c webiny-cms didn't add a newline on their update to .bashrc
    echo -e "# "                      		>> $HOME/.bashrc
    echo -e "# IOST Setup"                      >> $HOME/.bashrc
    echo -e "# "                      		>> $HOME/.bashrc
    echo -e "if [ -f "$HOME/.iost_env" ]; then" >> $HOME/.bashrc
    echo -e "  source $HOME/.iost_env"          >> $HOME/.bashrc
    echo -e "fi"                                >> $HOME/.bashrc
  else
    echo -e "---> $msg found IOST setup in [$HOME/.bashrc], will not add"
  fi

  echo -e ""                          >> $HOME/.iost_env
  echo -e "#"                         >> $HOME/.iost_env
  echo -e "# Start:  IOST setup"      >> $HOME/.iost_env
  echo -e "#"                         >> $HOME/.iost_env
  echo -e "export TOP_DIR=$TOP_DIR"                                            >> $HOME/.iost_env
  echo -e "export SCRIPT_DIR=$SCRIPT_DIR"                                      >> $HOME/.iost_env
  echo -e "export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost"     >> $HOME/.iost_env
  echo -e "alias IOST=\"cd $IOST_ROOT\""                                       >> $HOME/.iost_env

  # if the tar.gz exists, don't download again
  # https://golang.org/dl/go1.15.linux-amd64.tar.gz
  if [  ! -f "/tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz" ]; then
    echo -e "---> $msg did not find [/tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz], will download"  
    echo -e "---> $run cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
    cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz    >> $INSTALL_LOG 2>&1
  else
    echo -e "---> $msg found [/tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz], will not download" 
  fi

  echo -e "---> $run sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz            >> $INSTALL_LOG 2>&1
  gzip go${GOLANG_MANDATORY}.linux-amd64.tar                                           >> $INSTALL_LOG 2>&1


  echo -e "---> $run export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	               >> $INSTALL_LOG 2>&1
  echo -e "---> $run export GOPATH=$HOME/go" 			                       >> $INSTALL_LOG 2>&1

  echo -e "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	                       >> $HOME/.iost_env
  echo -e "export GOPATH=$HOME/go" 			                               >> $HOME/.iost_env

  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  export GOPATH=$HOME/go
  source $HOME/.iost_env
  source $HOME/.bashrc

  echo -e "---> $run mkdir -p $GOPATH/src && cd $GOPATH/src"
  mkdir -p $GOPATH/src && cd $GOPATH/src

  echo -e -n "---> $msg go version "
  GO_V=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
  if [ -z $GO_V ]; then
    echo -e "---> $msg error: $GOLANG_MANDATORY install failed, check $INSTALL_LOG"
    ERR=1
    exit 50
  else
    echo -e "$GO_V"
  fi

  echo -e "---> $msg done: iost_install_golang ()" | tee -a $INSTALL_LOG
}

#
#  iost_install_sdk_iostjs() -
#
iost_install_sdk_iostjs () {
  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#=------------------   IOST Install - Installing SDK iost.js  -------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"

  echo -e "---> $msg start: iost_install_sdk_iostjs ()" 		        | tee -a $INSTALL_LOG

  echo -e "---> $run cd $HOME/iost-unofficial " 			       
  cd $HOME/iost-unofficial                                                      >> $INSTALL_LOG 2>&1

  echo -e "---> $cmd git clone https://github.com/iost-official/iostjs.git" 	
  git clone https://github.com/iost-official/iost.js.git                        >> $INSTALL_LOG 2>&1

  echo -e "---> $run cd iost.js" 					       
  cd iost.js                                                                    >> $INSTALL_LOG 2>&1

  echo -e "---> $run npm install"					        
  npm install                                                                   >> $INSTALL_LOG 2>&1

  echo -e "  ---> $cmd sed -i 's/47.244.109.92/127.0.0.1/' examples/info.js"             
  sed -i 's/47.244.109.92/127.0.0.1/' examples/info.js			 		>> $INSTALL_LOG 2>&1

  cd -
  echo -e "---> $msg end: iost_install_sdk_iostjs ()" 				| tee -a $INSTALL_LOG

}

#
#  iost_install_sdk_go_sdk() -
#
iost_install_sdk_go_sdk () {
  echo -e ""; echo -e ""
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#=------------------   IOST Install - Installing SDK go-sdk   -------------=#"
  echo -e "#=-------------------------------------------------------------------------=#"

  echo -e "---> $msg start: iost_install_sdk_go_sdk()"  		        | tee -a $INSTALL_LOG

  echo -e "---> $run cd $HOME/go/src/github.com/iost-official"			
  cd "$HOME/go/src/github.com/iost-official"					>> $INSTALL_LOG 2>&1

  echo -e "---> $run git clone https://github.com/iost-official/go-sdk.git" 	
  git clone https://github.com/iost-official/go-sdk.git  			>> $INSTALL_LOG 2>&1

  echo -e "---> $run cd -"  							
  cd -  									>> $INSTALL_LOG 2>&1

  echo -e "---> $msg end: iost_install_sdk_go_sdk()"  				| tee -a $INSTALL_LOG

}

#  end: IOST install
# -------------------------------------------------------------------------------------------------



# -------------------------------------------------------------------------------------------------
#  start: IOST install

#
#  iost_install_iost_core  () - install the IOST core code
#
iost_install_iost_core () {

  echo -e ""; echo -e ""

  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "#=--------- IOST Install - install core                               -----=#"
  echo -e "#=-------------------------------------------------------------------------=#"
  echo -e "---> $msg start: iost_install_core ()" | tee -a $INSTALL_LOG


  echo -e "---> $msg setup the environment $HOME/.iost_env"
  source $HOME/.iost_env

  echo -e "---> $msg cd $GOPATH/src"
  cd $GOPATH/src
  echo -e "---> $msg go get -d github.com/iost-official/go-iost"
  go get -d github.com/iost-official/go-iost >> $INSTALL_LOG 2>&1

  echo -e "---> $msg use [cd $IOST_ROOT]"
  cd $IOST_ROOT

  echo -e "---> $run make build install"
  make build install >> $INSTALL_LOG 2>&1

  echo -e "---> $run cd vm/v8vm/v8"
  cd vm/v8vm/v8
  echo -e "---> $run make clean js_bin vm install"
  #make clean js_bin vm install
  make clean js_bin vm install deploy >> $INSTALL_LOG 2>&1
  make deploy                         >> $INSTALL_LOG 2>&1

  echo -e "---> $msg end: iost_install_core ()" | tee -a $INSTALL_LOG

}

#  end: IOST install
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
#  start: iServer start/stop/restart

#
#  iost_run() -  simply start the iServer
#
iost_run () {
  cd $IOST_ROOT
  nohup iserver -f config/iserver.yml 2>$SERVER_START_LOG >$SERVER_LOG&
  sleep 5
}


#
#  iost_stop() -  simply stop the iServer
#
iost_stop () {
  # check for a running iServer
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo -e "  ---> $msg iServer not running..."   				| tee -a $SERVER_LOG
  else
    kill -15 $tpid  >> $SERVER_LOG 2>&1
    sleep 5
  fi
}


#
#  iost_start_iserver() -  simply start iServer
#
iost_start_iserver () {

  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, not starting..." 			| tee -a $SERVER_LOG
    return 80
  fi

  # check for a running iServer
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo -e "  ---> $msg iServer not running, now starting..." 			| tee -a $SERVER_LOG
    iost_run
    iost_check_iserver
    echo -e "  ---> $msg iServer PID [$tpid]..." 				| tee -a $SERVER_LOG

    # the start log should have zero lines unless there is an error
    #if $(wc -l $SERVER_START_LOG >= 0) {
#
#      ERR=`cat $SERVER_START_LOG`
#      echo -e "  ---> $msg iServer start error:" 					| tee -a $SERVER_LOG
#      echo -e "  ---> $msg [$ERR]" 			 			| tee -a $SERVER_LOG
#    }
  else
    echo -e "  ---> $msg iServer running as pid [$tpid], no need to start "	| tee -a $SERVER_LOG
  fi
}


#
#  iost_stop_iserver() - gracefully shutdown iServer
#
iost_stop_iserver () {
  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, not stopping..." 			| tee -a $SERVER_LOG
    return 81
  fi

  # check for a running iServer
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo -e "  ---> $msg iServer not running..." | tee -a $SERVER_LOG
  else
    echo -e "  ---> $msg iServer running as pid [$tpid], now stopping..."
    iost_stop
    echo -e "  ---> $msg iServer stopped..." | tee -a $SERVER_LOG
  fi
}


#
#  iost_check_iserver() - confirm that local iServer is running
#  usage: if iost_check_server; then; echo -e "running"; fi
#  >=1 - successful, the iServer is running
#   =0 - not successful, the iServer is not running
iost_check_iserver () {
  if [ ! -r $HOME/.iost_env ]; then
    return 82
  fi

  # check for a running iServer
  tpid=$(pidof iserver);

  if (( $? == 1 )); then
    #echo -e "not running - not found tpid: $tpid";
    return 1
  else
    #echo -e "running - found tpid: $tpid";
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

  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, not restarting..."  		| tee -a $SERVER_LOG
    return 84
  else 
    # 0=running, 1=not running
    if iost_check_iserver; then
      # tpid - this is a global variable set in iost_check_iserver()
      echo -e "  ---> $msg iServer running at pid [$tpid], now stopping..."  	| tee -a $SERVER_LOG
      iost_stop
      echo -e "  ---> $msg iServer starting..." 					| tee -a $SERVER_LOG
      iost_run
    else
      echo -e "  ---> $msg iServer starting..."  					| tee -a $SERVER_LOG
      iost_run
    fi
  fi
}

#  end: iServer start/stop/restart
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
#  start: test functions

#  
#  iost_test_iwallet()
#
iost_test_iwallet () {

  # is IOST installed?
  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, cannot test iWallet..."  		| tee -a $SERVER_LOG
    return 84
  fi

  #  usage: if iost_check_server; then; echo -e "running"; fi
  #  >=1 - successful, the iServer is running
  #   =0 - not successful, the iServer is not running

  if iost_check_iserver; then
    # tpid - this is a global variable set in iost_check_iserver()
    echo -e "  ---> $msg iServer running at pid [$tpid]..."        | tee -a $SERVER_LOG
    source $HOME/.iost_env
    echo -e "  ---> $run iwallet state"
    iwallet state > $IWALLET_LOG 2>&1
    if (( $? >= 1 )); then
      echo -e ""; echo -e ""
      cat $IWALLET_LOG | more
      echo -e ""; echo -e ""
      echo -e "  ---> $err make sure iServer is running"
      return $?
    else
      read -p "  ---> $msg hit any key to view the test logs" ttLOGS
      cat $IWALLET_LOG | more
      read -p "  ---> $msg end of log, hit any key to continue" tIN
    fi
  else
    echo -e "  ---> $msg iServer not running, you should start it..." | tee -a $SERVER_LOG
  fi
}


#
#  iost_test_sdk_iostjs ()
#
iost_test_sdk_iostjs () {

  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, cannot test JavaScript SDK..."            | tee -a $SERVER_LOG
    return 84
  fi

  #  usage: if iost_check_server; then; echo -e "running"; fi
  #  >=1 - successful, the iServer is running
  #   =0 - not successful, the iServer is not running

  if iost_check_iserver; then

    source $HOME/.iost_env
    cd $TOP_DIR/iost.js/examples

    echo -e "  ---> $cmd cd $TOP_DIR/iost.js/examples"                                    | tee -a $SERVER_LOG

    echo -e "  ---> $run node info.js "
    node info.js > /tmp/iost.test.iost.js.txt 2>&1
    rc=$?

    if (( $rc >= 1 )); then
      echo -e "rc: $rc"; echo -e ""
      cat /tmp/iost.test.iost.js.txt | more
      echo -e ""; echo -e "";
      read -p "  ---> $err make sure iServer is running..." z
      return $rc
    else
      read -p "  ---> $msg hit any key to view the test logs" ttLOGS
      cat /tmp/iost.test.iost.js.txt | more
      read -p "  ---> $msg end of log, hit any key to continue" tIN
    fi
  else
    echo -e "  ---> $msg iServer not running, you should start it..." | tee -a $SERVER_LOG
  fi

}


#
#  iost_run_itests () - install the IOST core code
#
iost_run_itests () {

  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, cannot run iTest..."            | tee -a $SERVER_LOG
    return 84
  else 
    #  usage: if iost_check_server; then; echo -e "running"; fi
    #  >=1 - successful, the iServer is running
    #   =0 - not successful, the iServer is not running

    if iost_check_iserver; then

      echo -e "  ---> $cmd cd $IOST_ROOT/test"
      cd $IOST_ROOT 	>> $ITEST_LOG 2>&1
      cd test		      >> $ITEST_LOG 2>&1

      echo -e "  ---> $run itest run a_case"
      itest run a_case  >> $ITEST_LOG 2>&1

      echo -e "  ---> $run itest run t_case"
      itest run t_case  >> $ITEST_LOG 2>&1

      echo -e "  ---> $run itest run c_case"
      itest run c_case  >> $ITEST_LOG 2>&1

      echo -e "  ---> $run itest run cv_case"
      itest run cv_case >> $ITEST_LOG 2>&1

      read -p "  ---> hit any key to view the test logs" ttLOGS
      more $ITEST_LOG
      read -p "  ---> $msg end of log, hit any key to continue" tIN 
    else
      echo -e "  ---> $msg iServer not running, you should start it..." | tee -a $SERVER_LOG
    fi
  fi

}


#
#  iost_view_install_log ()
#
iost_view_install_log () {

  if [ -r /tmp/install.name.log ]; then
    echo -e ""
    echo -e "  ---> $msg view install log"
    echo -e ""; echo -e ""
    more `cat /tmp/install.name.log`
    echo -e ""; echo -e ""
    read -p "  ---> $msg end of log, any key to continue" tIN
    echo -e "";
  else
    echo -e ""
    read -p "  ---> $msg no install log present, any key to continue" tIN
    echo -e ""
    return 86
  fi 

}


#
#  iost_view_important_dev_info ()
#
iost_view_important_dev_info () {

  if [ ! -r $HOME/.iost_env ]; then
    echo -e "  ---> $msg iServer not installed, cannot test JavaScript SDK..."            | tee -a $SERVER_LOG
    return 84
  fi

  if [ -r "$TOP_DIR/docs/view_important_dev_info.sh" ]; then
    echo -e ""
    echo -e "  ---> $msg view important developer information"
    echo -e ""; echo -e ""
    envsubst < $TOP_DIR/docs/view_important_dev_info.sh | more
    #more `$HOME/iost-unofficial/docs/view_important_dev_info.sh`
    echo -e ""; echo -e ""
    read -p "  ---> $msg done, hit any key to continue" tIN
    echo -e "";
  else
    echo -e ""
    read -p "  ---> $msg no important developer information found, any key to continue" tIN
    echo -e ""
    return 86
  fi

}

#  end: test functions
# -------------------------------------------------------------------------------------------------

#
#  iost_baremetal_or_docker () - master setup func
#
iost_baremetal_or_docker ()  {
  clear

  echo -e "  #=--------------------------------------------------=#"
  echo -e "  #=--        IOST Install, Test, or Admin          --=#"
  echo -e "  #=--  https://github.com/iost-official/go-iost    --=#"
  echo -e "  #=--        Codebase Version: $IOST_RELEASE               --=#"
  echo -e "  #=--------------------------------------------------=#"
  echo -e ""
  echo -e "   1.  Install IOST on baremetal"
  echo -e "   2.  Install IOST with Docker" 
  echo -e ""

  read -p "  Select a number: " iNUM

  case "$iNUM" in

    1) echo -e ""
       IOST_DOCKER="0"
       IOST_BAREMETAL="1"
       iost_main_menu
    ;;

    2) echo -e ""
       IOST_DOCKER="1"
       IOST_BAREMETAL="0"
       iost_main_menu
    ;;

    *) echo -e ""
       iost_main_menu
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

#
#  iost_install_run_admin () 
#
iost_install_run_admin () {
  echo -e ""; echo -e "";
  read -p "---> $msg core IOST is installed, continue to the IOST Admin Menu? (Y/n): " tADM

  if [ ! -z "$tADM" ]; then
    if [ $tADM == "n" ] || [ $tADM == 'N' ] || [ $tADM == '' ]; then
        exit 0
    else
        iost_main_menu
    fi
  fi
}


# -------------------------------------------------------------------------------------------------
#  START : sub_menu_components


#
#  iost_sub_menu_components() - install/reinstall/remove individual components
#
iost_sub_menu_components ()  {
  clear

  echo -e "  ${dg}#=--------------------------------------------------=#${zz}"
  echo -e "  ${dg}#=--        IOST Install/Reinstall/Remove         --=#${zz}"
  echo -e "  ${dg}#=--            Individual Compoents              --=#${zz}"
  echo -e "  ${dg}#=--------------------------------------------------=#${zz}"
  echo -e ""
  echo -e "   1.  ${ly}Reinstall golang${zz}"
  echo -e ""
  echo -e "   2.  ${ly}Reinstall IOST${zz}"
  echo -e ""
  echo -e "  99.  ${ly}Return to main menu${zz}"
  echo -e ""

  read -p "  Select a number: " iNUM

  case "$iNUM" in

    1) echo -e ""
       iost_install_golang
       read -p "---> $msg finished, hit any key to continue" tIN
    ;;

    2) echo -e ""
       iost_stop_iserver
       iost_install_iost_core
       read -p "---> $msg finished, hit any key to continue" tIN
    ;;

    *) echo -e ""
       iost_main_menu
    ;;

    esac
}




#
#  iost_main_menu () 
#  - main menu
#  - bypassed if UNATTENDED=1
#
iost_main_menu ()  {
  clear

  # hoover up the environment
  if [ -r $HOME/.iost_env ]; then
    source $HOME/.iost_env
  fi

  echo -e "  $dg#=--------------------------------------------------=#$zz"
  echo -e "  $dg#=--        IOST Install/Test/Admin Script        --=#$zz"
  echo -e "  $dg#=--  https://github.com/iost-official/go-iost    --=#$zz"
  echo -e "  $dg#=--        Codebase Version: $IOST_RELEASE               --=#$zz"
  echo -e "  $dg#=--------------------------------------------------=#$zz"

  echo -e ""
  echo -e "    1.  ${ly}IOST Install development environment$zz"
  echo -e "    2.  ${ly}IOST Uninstall development environment$zz"
  echo -e ""
  echo -e "    3.  ${ly}iServer start local node$zz"
  echo -e "    4.  ${ly}iServer stop local node$zz"
  echo -e "    5.  ${ly}iServer restart local node$zz"
  echo -e ""
  echo -e "    6.  ${ly}Test local node status with iWallet${zz}"
  echo -e "    7.  ${ly}Test local node with iTest${zz}"
  echo -e "    8.  ${ly}Test local node status with JavaScript SDK${zz}"
  echo -e ""
  echo -e "    9.  ${ly}dApp run example smart contract${zz}"
  echo -e ""
  echo -e "   10.  ${ly}Open the command line interface${zz}"
  echo -e "   11.  ${ly}View last install log${zz}"
  echo -e "   12.  ${ly}View important developer information${zz}"
  echo -e ""
  echo -e "   13.  ${ly}Submenu for individual components${zz}"
  echo -e ""
  echo -e "   99.  ${lr}Quit${zz}"
  echo -e ""

  read -p "  Select a number: " iNUM

  case "$iNUM" in

    1) iost_admin_or_install
       iost_install_init 
       iost_warning_requirements
       iost_install_packages
       iost_install_nvm_node_npm

       if [ $DOCKER_USE -eq '1' ]; then
         iost_install_docker
       fi

       iost_install_golang
       iost_install_iost
       iost_install_sdk_iostjs
       iost_install_sdk_go_sdk
       iost_install_run_admin 
       iost_run 
    ;;

    2) echo -e ""
       iost_install_rmfr
       read -p "---> $msg uninstalled, hit any key to continue" tIN
       iost_main_menu
    ;;

    3) echo -e ""
       iost_start_iserver
       read -p "  ---> $msg hit any key to continue" tIN
       iost_main_menu
    ;;

    4) echo -e ""
       iost_stop_iserver
       read -p "  ---> $msg hit any key to continue" tIN
       iost_main_menu
    ;;

    5) echo -e ""
       iost_restart_iserver
       read -p "  ---> $msg hit any key to continue" tIN
       iost_main_menu
    ;;

    6) iost_test_iwallet
       read -p "  ---> $msg hit any key to continue" tIN
       iost_main_menu
    ;;

    7) iost_run_itests
       read -p "  ---> $msg hit any key to continue" tIN
       iost_main_menu
    ;;

    8) iost_test_sdk_iostjs 
       read -p "  ---> $msg hit any key to continue" tIN
       iost_main_menu
    ;;

    9) echo -e "   ---> $msg opening a /bin/bash, type exit or CTRL-D to return"
       echo -e ""
       /bin/bash
       iost_main_menu
    ;;



    10) echo -e "   ---> $msg opening a /bin/bash, type exit or CTRL-D to return"
       echo -e ""
       /bin/bash
       iost_main_menu
    ;;

   11) iost_view_install_log
       iost_main_menu
    ;;

   13) iost_sub_menu_components
       iost_main_menu
    ;;


    99) echo -e ""
        exit
    ;;

  esac
}



###
###   START - beginning of the install script
###
#set -e

iost_main_menu




###
###   END - the end of the install script
###
