#!/bin/bash  

clear

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
#             IOST "One Click" Install     
#              Development Environment     
#            Best for Greenfield Installs    
#        Debian/Ubuntu/Redhat full VM or container
#
#  Sat Apr 20 06:40:40 UTC 2019
#
#  Objective:  to provide a single script that will install
#  all the necessary dependecies and IOST code required to be
#  productive in less than 15 minutes.  
#
#  This is a greenfield install only, so only use on a fresh 
#  install of Linux.  It will check for previous install attemps, 
#  remove all the prevous installed dependicies, including config
#  or source that you may have modified, and start the install 
#  again.  
#
#  Admin Menu that will
#  - IOST Install
#  - IOST Removal
#  - iServer start/stop/restart
#  - run itest 
#  - view install log
#  - kkk
#
#  We'll install the following: 
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


# IOST release version: https://github.com/iost-official/go-iost
readonly IOST_RELEASE="3.0.9"


# Dependicies
readonly GOLANG_MANDATORY="1.12.4"
readonly NODE_MANDATORY="v10.15.3"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.34.0"
readonly DOCKER_MANDATORY="v18.06.0-ce"


# package.io not supported on cosmic yet
# Supported UNIX distributions
readonly UBUNTU_MANDATORY=('16.04' '16.10' '18.04');  	# Ubuntu 'xenial' 'yakkety' 'bionic'
readonly CENTOS_MANDATORY=('centos7' 'rhel');		# Redhat & CentOS
readonly DEBIAN_MANDATORY=('stretch');			# Debian Stretch
readonly MACOS_MANDATORY=('Darwin', 'Hitchens');        # OSX 


# misc unused flags - use later for automatic install
readonly IOST_UNATTENDED=""				# unattended install
readonly IOST_CLEAN_INSTALL="0"				# unattended install, force remove of previous IOST install
readonly VAGRANT_USE=""					# use Vagrant box
readonly DOCKER_USE="0"    				# 1-yes | 0-no


# install and blockchain logs
readonly INSTALL_LOG="/tmp/bootstrap.sh.$$.log"		# stdout & stderr
readonly SERVER_LOG="/tmp/iserver.$$.log"		# stdout 
readonly SERVER_START_LOG="/tmp/iserver.start.$$.log"	# stdout 
readonly SERVER_ERR_LOG="/tmp/iserver.err.$$.log"	# stderr
readonly ITEST_LOG="/tmp/itest.$$.log"			# stdout & stderr
readonly IWALLET_LOG="/tmp/iwallet.$$.log"		# stdout & stderr

# variables
IOST_DOCKER=""
IOST_BAREMETAL=""

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#  NO NEED TO MODIFY BELOW THIS LINE UNLESS THE BUILD IS TOTALLY BROKEN
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

source libs/ui.sh

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
#  iost_distro_detect() - 
#
iost_distro_detect () {

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
          #dev_tools_purge="sudo $pkg_installer groupinstall "\"Development Tools\""
          echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          ;;

        debian)
          # check version is supported
          if echo ${DEBIAN_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_installer="/usr/bin/apt-get -y"
            # setup packages-debian.txt
            echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo "---> err: [$VERSION_ID] [${PRETTY_NAME}] is not supported, view $INSTALL_LOG"
            exit 77
          fi
          ;;
        ubuntu)
            if echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_bare="/usr/bin/apt-get "
            pkg_installer="/usr/bin/apt-get -y "
            pkg_purge=" purge "
            pkg_yes=" -y "
            git_lfs="curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
            dev_tools="$pkg_installer software-properties-common  build-essential"
            dev_tools_purge="$pkg_installer  purge software-properties-common  build-essential"
            # setup packages-ubuntu.txt
            echo "---> $OK_COLOR msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo "---> $ERROR_COLOR err: [${PRETTY_NAME}] is not supported, view $INSTALL_LOG"
            exit 76
          fi
          ;;

        *)
          echo "---> err: the package installer for [$PRETTY_INSTALLER] is unsupported, view $INSTALL_LOG"
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
  echo "$INSTALL_LOG" > /tmp/install.name.log
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - pre-init      -------------------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_init () " | tee -a $INSTALL_LOG

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
  sudo $(pwd)/exit.sh
  if (( $? >= 1 )); then
    echo "---> err: cannot [sudo]"
    exit; 98
  fi


  #
  #  determine distro and set variables
  #
  iost_distro_detect


  #
  #  check that git is installed
  #
  #command -v git >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
  if exists git; then
    echo "---> run: $pkg_installer install git"
    sudo $pkg_installer install git  >> $INSTALL_LOG 2>&1
  else
    mygit=$(git --version 2>/dev/null)
    echo "---> msg: $mygit already installed"
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
  # -  IOST: iwallet, iServer, scaf, 
  #
  if [ -f "$HOME/.iost_env" ]; then
    echo "---> irk: previous IOST install found!"
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

  echo "---> msg: done: iost_install_init () " | tee -a $INSTALL_LOG
	
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
  # -  IOST: iwallet, iServer, scaf, 


  #
  #  saturate environment
  #
  source ~/.iost_env

  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - removing previous install  ------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_rmfr () " | tee -a $INSTALL_LOG
  echo "---> msg: view log file: $INSTALL_LOG"
  #
  #  determine distro and set variables
  #
  iost_distro_detect


  if [ $DOCKER_USE -eq '1' ]; then
    echo "---> run: sudo systemctl disable docker-ce"
    sudo systemctl disable docker >> $INSTALL_LOG 2>&1
    echo "---> run: sudo systemctl stop docker-ce"
    sudo systemctl stop docker >> $INSTALL_LOG 2>&1
    sudo $pkg_installer $pkg_purge docker-ce >> $INSTALL_LOG 2>&1

    if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
      echo "---> run: sudo rm -fr /etc/apt/sources.list.d/docker.list" 
      sudo rm -fr /etc/apt/sources.list.d/docker.list
    fi
  fi

  echo "---> run: sudo $pkg_installer $pkg_purge libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev  "
  sudo $pkg_installer $pkg_purge libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev    >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer $pkg_purge git git-lfs software-properties-common  build-essential curl  " 
  sudo $pkg_installer $pkg_purge git git-lfs software-properties-common  build-essential curl    >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $dev_tools_purge" 
  sudo $dev_tools_purge                           >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer $pkg_purge apt-transport-https  "
  sudo $pkg_installer $pkg_purge apt-transport-https    >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer autoremove  " 
  sudo $pkg_installer autoremove                   >> $INSTALL_LOG 2>&1

  if [ -f "$HOME/.iost_env" ]; then
    echo "---> run: rm -fr $HOME/.iost_env"
    rm -fr $HOME/.iost_env
  fi

  unset NVM_DIR
  if [ -d "$HOME/.nvm" ]; then
    echo "---> run: rm -fr $HOME/.nvm" 
    rm -fr $HOME/.nvm
  fi

  # remove IOST source
  if [ -d "$HOME/go/src/github.com/iost-official/go-iost" ]; then
    echo "---> run: rm -fr $HOME/go/src/github.com/iost-official/go-iost" 
    rm -fr $HOME/go/src/github.com/iost-official/go-iost
  fi


  echo "---> msg: done: iost_install_rmfr () " | tee -a $INSTALL_LOG

}


#
#  iost_warning_requirements () - 
#
iost_warning_requirements () {
  
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - warning and requirements   ------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  #echo "Please read carefully as these are hard requirements:"; echo ""
  #echo "  1.  Do not install on a configured system."
  #echo "  2.  Run as a user that can sudo to root (man visudo)."
  echo ""; echo "";


  echo "This script will install the following:"; echo ""
  echo "  -  updaets for $PRETTY_NAME"
  echo "  -  nvm version $NVM_MANDATORY"
  echo "  -  node version $NODE_MANDATORY"
  echo "  -  npm version $NPM_MANDATORY"
  echo "  -  nvm version $NVM_MANDATORY"
  echo "  -  Go Lang verson $GOLANG_MANDATORY"

  if [ $DOCKER_USE -eq '1' ]; then
    echo "  -  docker version $DOCKER_MANDATORY"
  fi
  #echo "  -  Many packages; software-properties-common, build-essential, curl, git, git-lfs, and more"
  echo "  -  IOST release $IOST_RELEASE"
  echo ''
  echo "Install log is located:  $INSTALL_LOG "
  echo ''

  read -p "Continue?  (Y/n): " CONT

  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ] || [ $CONT == '' ]; then
      echo ""; echo ""
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

  echo "---> msg: start: iost_install_packages()" | tee -a $INSTALL_LOG

  #$sec_updt=$($pkg_installer list --upgradable | grep security | wc -l)
  #$reg_updt=$($pkg_installer list --upgradable | wc -l)

  echo "---> run: sudo $pkg_installer install apt-transport-https ca-certificates "
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $INSTALL_LOG 2>&1

  #echo "---> msg: $sec_updt security udpates and $reg_updt regular updates needed"
  #if (( $reg_updt >= 25 )); then
  #  echo "---> msg: NOTE: given the large number if updagtes, this may take a while"
  #fi

  echo "---> run: sudo $pkg_installer update"
  sudo $pkg_installer update                               >> $INSTALL_LOG 2>&1

  # 2019/04/18 - 18.04 cannot run unattended (grub and ??) 18.04
  DEBIAN_FRONTEND=noninteractive sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >> $INSTALL_LOG 2>&1
  echo "---> run: sudo $pkg_installer upgrade "
  sudo $pkg_installer upgrade                              >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer install software-properties-common "
  sudo $pkg_installer install software-properties-common   >> $INSTALL_LOG 2>&1

  #echo "---> run: sudo add-apt-repository ppa:git-core/ppa "
  #sudo add-apt-repository ppa:git-core/ppa  -y            >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $dev_tools"
  sudo $dev_tools                                          >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer install build-essential curl git "
  sudo $pkg_installer install build-essential curl git     >> $INSTALL_LOG 2>&1

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
  sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer install git-lfs"
  sudo $pkg_installer install git-lfs >> $INSTALL_LOG 2>&1

  echo "---> run: git lfs install"
  git lfs install >> $INSTALL_LOG 2>&1
  echo "---> msg: done: iost_install_packages()" | tee -a $INSTALL_LOG

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
  echo "---> msg: start: iost_install_nvm_node_npm ()"  | tee -a $INSTALL_LOG
  cd $HOME
  echo "---> run: curl -s https://raw.githubusercontent.com/creationix/nvm/${NVM_MANDATORY}/install.sh | bash"   
  curl -s https://raw.githubusercontent.com/creationix/nvm/${NVM_MANDATORY}/install.sh | bash      >> $INSTALL_LOG 2>&1

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


  echo "export NVM_DIR=$HOME/.nvm"                                          >> $HOME/.iost_env
  echo "[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh""                   >> $HOME/.iost_env 
  echo "[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"" >> $HOME/.iost_env  

  echo "---> run: nvm install $NODE_MANDATORY "
  nvm install $NODE_MANDATORY   >> $INSTALL_LOG 2>&1

  echo "---> run: npm i yarn"
  npm i yarn  >> $INSTALL_LOG 2>&1

  echo -n '---> msg: nvm version '
  NVM_V=$(nvm --version 2>/dev/null)
  if [ -z $NVM_V ]; then
    echo ""; echo "---> msg: error: nvm install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo "$NVM_V"
  fi

  echo -n '---> msg: npm version '
  NPM_V=$(npm --version 2>/dev/null)
  if [ -z $NPM_V ]; then
    echo ""; echo "---> msg: error: npm install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo "$NPM_V"
  fi

  echo -n '---> msg: node version '
  NODE_V=$(node --version 2>/dev/null)
  if [ -z $NODE_V ]; then
    echo ""; echo "---> msg: error: node install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo "$NODE_V"
  fi

  if (( $ERR == 1 )); then
    echo '---> err: one or more of the folloing failed to install: nvm, node, npm'
    exit 55
  fi

  echo "---> msg: nvm, node, and npm installed"
  echo "---> msg: done: iost_install_nvm_node_npm ()"  | tee -a $INSTALL_LOG
}



#
#  iost_install_docker () - 
#
iost_install_docker () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#=------------------   IOST Install - Installing Docker    ----------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_docker ()" | tee -a $INSTALL_LOG

  echo "---> run: sudo $pkg_installer install apt-transport-https ca-certificates  >> $INSTALL_LOG 2>&1"
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $INSTALL_LOG 2>&1

  echo "---> run: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> $INSTALL_LOG 2>&1

  echo "---> run: git_docker="$(packages/${DIST}_${VERSION_ID}.sh >> $INSTALL_LOG 2>&1)"";
  git_docker="$(packages/${DIST}_${VERSION_ID}.sh >> $INSTALL_LOG 2>&1)"

  #lsb=$(lsb_release -cs)
  #echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $lsb stable" | sudo tee /etc/apt/sources.list.d/docker.list  >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer update"
  sudo $pkg_installer update                >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer install docker-ce "
  sudo $pkg_installer install docker-ce     >> $INSTALL_LOG 2>&1

  # Add user account to the docker group
  echo "---> run: sudo usermod -aG docker $(whoami) "
  sudo usermod -aG docker $(whoami)         >> $INSTALL_LOG 2>&1

  echo "---> run: systemctl enable docker"
  sudo systemctl enable docker              >> $INSTALL_LOG 2>&1
  echo "---> run: systemctl run docker"
  sudo systemctl run docker                 >> $INSTALL_LOG 2>&1

  echo -n '---> msg: docker version '
  DOCKER_V=$(docker --version 2>/dev/null)
  if [ -z $DOCKER_V ]; then
    echo "---> msg: error: docker-ce install failed, check $INSTALL_LOG"
    ERR=1
  else
    echo "$DOCKER_V"
  fi

  echo "---> msg: done: iost_install_docker ()" | tee -a $INSTALL_LOG
}


#
#  iost_install_golang() - 
#
iost_install_golang () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#=------------------   IOST Install - Installing Golang    ----------------=#"
  echo "#=-------------------------------------------------------------------------=#"

  echo "---> msg: start: iost_install_golang ()" | tee -a $INSTALL_LOG
  IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"
  alias IOST="cd $IOST_ROOT"

  # check for logic that sources IOST env file
  CHK_SETUP=$(grep "IOST setup" $HOME/.bashrc > /dev/null >&1)  
  if [ -z "$CHK_SETUP" ]; then 
    echo "---> msg: did not find IOST setup in .bashrc, adding"
    # insert a blank line b/c webiny-cms didn't add a newline on their update to .bashrc
    echo ""                                  >> $HOME/.bashrc
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
    rm -fr /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz                               >> $INSTALL_LOG 2>&1
  fi

  echo "---> run: cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz    >> $INSTALL_LOG 2>&1

  echo "---> run: sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz                 >> $INSTALL_LOG 2>&1

  echo "---> run: export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	               >> $INSTALL_LOG 2>&1
  echo "---> run: export GOPATH=$HOME/go" 			                       >> $INSTALL_LOG 2>&1

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
    echo "---> msg: error: $GOLANG_MANDATORY install failed, check $INSTALL_LOG"
    ERR=1
    exit 50
  else
    echo "$GO_V"
  fi

  echo "---> msg: done: iost_install_golang ()" | tee -a $INSTALL_LOG
}

#  end: IOST install
# -------------------------------------------------------------------------------------------------



# -------------------------------------------------------------------------------------------------
#  start: IOST install

#
#  iost_install_iost_core  () - install the IOST core code
#
iost_install_iost_core () {

  echo ""; echo ""

  echo "#=-------------------------------------------------------------------------=#"
  echo "#=--------- IOST Install - install core                               -----=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_core ()" | tee -a $INSTALL_LOG


  echo "---> msg: setup the environment $HOME/.iost_env"
  source $HOME/.iost_env

  ###go get -d github.com/iost-official/go-iost
  ###cd github.com/iost-official/go-iost/

  #echo "---> msg: env | grep GO"
  #res=$(env | grep GO > /dev/null 2>&1)
  #echo "---> msg: res [$res]"

  echo "---> msg: cd $GOPATH/src"
  cd $GOPATH/src
  echo "---> msg: go get -d github.com/iost-official/go-iost"
  go get -d github.com/iost-official/go-iost >> $INSTALL_LOG 2>&1

  echo "---> msg: use [cd $IOST_ROOT]"
  cd $IOST_ROOT

  echo "---> run: make build install"
  make build install >> $INSTALL_LOG 2>&1

  echo "---> run: cd vm/v8vm/v8"
  cd vm/v8vm/v8
  echo "---> run: make clean js_bin vm install"
  #make clean js_bin vm install
  make clean js_bin vm install deploy >> $INSTALL_LOG 2>&1
  make deploy                         >> $INSTALL_LOG 2>&1

  echo ""; echo "";
  read -p "---> msg: core IOST is installed, continue to the IOST Admin Menu? (Y/n): " tADM

  if [ ! -z "$tADM" ]; then
    if [ $tADM == "n" ] || [ $tADM == 'N' ] || [ $tADM == '' ]; then
        exit 0
    else
        iost_main_menu
    fi
  fi

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
    echo "  ---> msg: iServer not running..."   				| tee -a $SERVER_LOG
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
    echo "  ---> msg: iServer not installed, not starting..." 			| tee -a $SERVER_LOG
    return 80
  fi

  # check for a running iServer
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo "  ---> msg: iServer not running, now starting..." 			| tee -a $SERVER_LOG
    iost_run

    # the start log should have zero lines unless there is an error
    #if $(wc -l $SERVER_START_LOG >= 0) {
#
#      ERR=`cat $SERVER_START_LOG`
#      echo "  ---> msg: iServer start error:" 					| tee -a $SERVER_LOG
#      echo "  ---> msg: [$ERR]" 			 			| tee -a $SERVER_LOG
#    }
  else
    echo "  ---> msg: iServer running as pid [$tpid], no need to start "	| tee -a $SERVER_LOG
  fi
}


#
#  iost_stop_iserver() - gracefully shutdown iServer
#
iost_stop_iserver () {
  if [ ! -r $HOME/.iost_env ]; then
    echo "  ---> msg: iServer not installed, not stopping..." 			| tee -a $SERVER_LOG
    return 81
  fi

  # check for a running iServer
  tpid=$(pidof iserver);
  if [ -z $tpid ]; then
    echo "  ---> msg: iServer not running..." | tee -a $SERVER_LOG
  else
    echo "  ---> msg: iServer running as pid [$tpid], now stopping..."
    iost_stop
    echo "  ---> msg: iServer stopped..." | tee -a $SERVER_LOG
  fi
}


#
#  iost_check_iserver() - confirm that local iServer is running
#  usage: if iost_check_server; then; echo "running"; fi
#  >=1 - successful, the iServer is running
#   =0 - not successful, the iServer is not running
iost_check_iserver () {
  if [ ! -r $HOME/.iost_env ]; then
    return 82
  fi

  # check for a running iServer
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

  if [ ! -r $HOME/.iost_env ]; then
    echo "  ---> msg: iServer not installed, not restarting..."  		| tee -a $SERVER_LOG
    return 84
  fi

  local tPID

  # 0=running, 1=not running
  if iost_check_iserver; then
    # tpid - this is a global variable set in iost_check_iserver()
    echo "  ---> msg: iServer running at pid [$tpid], now stopping..."  	| tee -a $SERVER_LOG
    iost_stop
    echo "  ---> msg: iServer starting..." 					| tee -a $SERVER_LOG
    iost_run
  else
    echo "  ---> msg: iServer starting..."  					| tee -a $SERVER_LOG
    iost_run
    #tPID=$(iost_start_iserver)
    #read -p "  ---> msg: iServer log is located: $SERVER_LOG, hit any key to continue"
  fi

}

#  end: iServer start/stop/restart
# -------------------------------------------------------------------------------------------------


#  
#  iost_test_iwallet()
#
iost_test_iwallet () {

  if [ ! -r $HOME/.iost_env ]; then
    echo "  ---> msg: iServer not installed, cannot test iWallet..."  		| tee -a $SERVER_LOG
    return 84
  else
    source $HOME/.iost_env
    echo "---> run: iwallet state"
    iwallet state > $IWALLET_LOG 2>&1

    if (( $? >= 1 )); then
      echo ""; echo ""
      cat $IWALLET_LOG | more
      echo ""; echo ""
      echo "  ---> err: make sure iServer is running"
      return $?
    else 
      cat $IWALLET_LOG | more
    fi
  fi
}


#
#  iost_run_itests () - install the IOST core code
#
iost_run_itests () {

  echo ''; echo ''

  echo "  #=--------------------------------------------------=#"
  echo "  #=--------- IOST Install Administration Menu  ------=#"
  echo "  #=-- itest run a_case, t_case, c_case, cv_case  ----=#"
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
#  iost_view_install_log ()
#
iost_view_install_log () {

  if [ -r /tmp/install.name.log ]; then
    echo ""
    echo "  ---> msg: view install log"
    echo ""; echo ""
    more `cat /tmp/install.name.log`
    echo ""; echo ""
    read -p "  ---> msg: end of log, any key to continue" tIN
    echo "";
  else
    echo ""
    read -p "  ---> msg: $ERROR_COLOR no install log present, any key to continue" tIN
    echo ""
    return 86
  fi 

}


#
#  iost_install_iost () - master setup func
#
iost_baremetal_or_docker ()  {
  clear

  echo "  #=--------------------------------------------------=#"
  echo "  #=--        IOST Install, Test, or Admin          --=#"
  echo "  #=--  https://github.com/iost-official/go-iost    --=#"
  echo "  #=--        Codebase Version: $IOST_RELEASE               --=#"
  echo "  #=--------------------------------------------------=#"
  echo ""
  echo "   1.  Install IOST on baremetal"
  echo "   2.  Install IOST with Docker" 
  echo ""

  read -p "  Select a number: " iNUM

  case "$iNUM" in

    1) echo ""
       IOST_DOCKER="0"
       IOST_BAREMETAL="1"
       iost_main_menu
    ;;

    2) echo ""
       IOST_DOCKER="1"
       IOST_BAREMETAL="0"
       iost_main_menu
    ;;

    *) echo ""
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

  echo "  #=--------------------------------------------------=#"
  echo "  #=--        IOST Install/Test/Admin Script        --=#"
  echo "  #=--  https://github.com/iost-official/go-iost    --=#"
  echo "  #=--        Codebase Version: $IOST_RELEASE               --=#"
  echo "  #=--------------------------------------------------=#"

  echo ""
  echo "    1.  IOST Install development environment"
  echo "    2.  IOST Uninstall development environment"
  echo ""
  echo "    3.  iServer start local node"
  echo "    4.  iServer stop local node"
  echo "    5.  iServer restart local node"
  echo ""
  echo "    6.  Run iWallet to check node status"
  echo "    7.  Run iTest suite"
  echo "    8.  Run test dApp"
  echo ""
  echo "    9.  Open the command line interface"
  echo "   10.  View last install log"
  echo ""
  echo "   99.  Quit"
  echo ""

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
       iost_run 
    ;;

    2) echo ""
       iost_install_rmfr
       read -p "---> msg: uninstalled, hit any key to continue" tIN
       iost_main_menu
    ;;

    3) echo ""
       iost_start_iserver
       read -p "  ---> msg: hit any key to continue" tIN
       iost_main_menu
    ;;

    4) echo ""
       iost_stop_iserver
       read -p "  ---> msg: hit any key to continue" tIN
       iost_main_menu
    ;;

    5) echo ""
       iost_restart_iserver
       read -p "  ---> msg: hit any key to continue" tIN
       iost_main_menu
    ;;

    6) echo ""
       iost_test_iwallet
       read -p "  ---> msg: hit any key to continue" tIN
       iost_main_menu
    ;;

    7) echo ""
       echo "  ---> msg: running iTests"
       iost_run_iserver
       iost_run_itests
       iost_main_menu
    ;;

    8) clear
       echo ""
       echo "   ---> msg: opening a /bin/bash, type exit or CTRL-D to return"
       /bin/bash
       iost_main_menu
    ;;

    9) echo "   ---> msg: opening a /bin/bash, type exit or CTRL-D to return"
       /bin/bash
       iost_main_menu
    ;;

   10) iost_view_install_log
       iost_main_menu
    ;;


    99) echo ""
        exit
    ;;

  esac
}



###
###   START - beginning of the install script
###
#set -e

iost_main_menu
#iost_baremetal_or_docker
#iost_install_init
#iost_warning_requirements
#iost_install_packages
#iost_install_nvm_node_npm
#iost_install_docker
#iost_install_golang
#iost_install_iost
#iost_run





###
###   END - the end of the install script
###
