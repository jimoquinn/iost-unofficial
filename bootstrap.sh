#!/bin/bash 

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
#             IOST Developer Ecosystem 
#           Greenfield Install for Ubuntu  
#
#  Objective:  to provide all the tools necessary to 
#  do all types of development in the IOST ecosystem.
#  Including dapps, blockchain, wallet, server, etc.
#
#  This is a greenfield install only, but I've had success 
#  restarting the installation several times with no real 
#  consequences except for a messy .bashrc. 
#
#  With the exception of Go and some packages, it will
#  download, compile the source code, and install the 
#  tools.  Then it will download and compile all the
#  IOST code necessary to start developing in the
#  ecosystem.
#
#
#  Ubuntu 18.04 is required, we'll install:
#  - updates and patches
#  - git, git-lfs, build-essentials, and many more
#  - RocksDB
#  - Go 
#  - nvm
#  - npm 
#  - node
#  - docker
#  - k8s
#
#  IOST from github.com/iost-official/go-iost
#  - wallet - named iwallet
#  - node - iserver
#  - VM - virtual machiens for dapps called V8VM
#
#  Report bugs to:
#  https://github.com/jimoquinn/iost-unofficial
#
#  You can contact me here:
#  jim.oquinn@gmail.com
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# set to 1 if you'd like to clean up previous install attempts
readonly IOST_CLEAN_INSTALL="1"


# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# the version we're looking for
readonly UBUNTU_MANDATORY=('xenial' 'yakkety' 'bionic'  'cosmic');
readonly CENTOS_MANDATORY=('centos7');
readonly DEBIAN_MANDATORY=('stretch');
#readonly MACOS_MANDATORY=('Darwin', 'Hitchens');

readonly ROCKSDB_MANDATORY="v5.14.3"
readonly GOLANG_MANDATORY="1.11.3"
readonly NODE_MANDATORY="v10.14.2"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.33.11"
readonly DOCKER_MANDATORY="v18.06.0-ce"

readonly IOST_MANDATORY=""
# set to "1" if this is to be used in a Vagrantfile as provision
readonly FOR_VAGRANT="1"	


readonly LOG="/tmp/bootstrap.sh.$$.log"



# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#  NO NEED TO MODIFY BELOW THIS LINE UNLESS THE BUILD IS TOTALLY BROKEN
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#
# list of functions
# 
# iost_warning_reqirements()
# iost_sudo_confirm()
# iost_install_packages()
# iost_install_rocksdb()
# iost_install_nvm_node_npm()
# iost_install_docker()
# iost_install_golang()
# iost_check_deps()

#
# 
#
iost_install_init ()  {
}


#
# 
#
iost_install_rm ()  {
}


#
# 
#
iost_install_end ()  {
}



#
# 
#
iost_ubuntu_options ()  {
  echo 'This script can install IOST on the following:'
  echo '  1.  Vagrant and LXC'
  echo '  2.  Kubernetes and Docker'
  echo '  3.  VMware'
  echo '  4.  Vagrant and VirtualBox'
  echo "  4.  Greenfield (aka; bare metal)"
}

iost_os_detect ()  {
  #echo 'This script can install the following:'
  #echo '  1.  Linux: Vagrant   LXC        Ubuntu 18.10 \(Cosmic\)'
  #echo '  2.  Linux: Vagrant   LXC        Ubuntu 18.04 \(Bionic\)'
  #echo '  3.  Linux: Vagrant   LXC        Ubuntu 16.04 \(Bionic\)'
  #echo '  4.  Linux: Vagrant   LXC        Ubuntu 16.04 \(Bionic\)'
  #echo '  5.  Linux: Vagrant   LXC        CentOS 7 '
  #echo '  6.  Linux: Vagrant   LXC        Debian Stretch 9'
  #echo '  7.  Linux: Vagrant   VMware     Ubuntu 18.04 \(Bionic\)'
  #echo '  8.  Linux: Vagrant   VMware     Ubuntu 18.10 \(Cosmic\)'
  #echo '  9.  Linux: Vagrant   VMware     Ubuntu 18.04 \(Bionic\)'
  #echo ' 10.  Linux: Vagrant   VMware     Ubuntu 16.04 \(Bionic\)'
  #echo ' 11.  Linux: Vagrant   VMware     Ubuntu 16.04 \(Bionic\)'
  #echo ' 12.  Linux: Vagrant   VMware     CentOS 7' 
  #echo ' 13.  Linux: Vagrant   VMware     Debian Stretch 7' 
  #echo ' 14.  Linux: Vagrant   VirtualBox Ubuntu 18.04 \(Bionic\)'
  #echo ' 15.  Linux: Vagrant   VirtualBox Ubuntu 18.10 \(Cosmic\)'
  #echo ' 16.  Linux: Vagrant   VirtualBox Ubuntu 18.04 \(Bionic\)'
  #echo ' 17.  Linux: Vagrant   VirtualBox Ubuntu 16.04 \(Bionic\)'
  #echo ' 18.  Linux: Vagrant   VirtualBox Ubuntu 16.04 \(Bionic\)'
  #echo ' 19.  Linux: Vagrant   VirtualBox CentOS 7' 
  #echo ' 20.  Linux: Vagrant   VirtualBox Debian Stretch 7'

  tOS=$(uname)
  case $tOS in
    'Linux')

	# /etc/os-release
	# PRETTY_NAME="Debian GNU/Linux 9 (stretch)"
	# NAME="Debian GNU/Linux"
	# VERSION_ID="9"
	# VERSION="9 (stretch)"
	# ID=debian
	# HOME_URL="https://www.debian.org/"
	# SUPPORT_URL="https://www.debian.org/support"
	# BUG_REPORT_URL="https://bugs.debian.org/"

        # /etc/os-release



      #declare -a versions=('xenial' 'yakkety', 'bionic', 'cosmic');
      # check the version and extract codename of ubuntu if release codename not provided by user
      if [ -z "$1" ]; then
        source /etc/lsb-release || \
          (echo "---> msg: ERROR: Release information not found, run script passing Ubuntu version codename as a parameter"; exit 1)
        OS=${DISTRIB_CODENAME}
      else
        OS=${1}
      fi


#      check version is supported
      if  echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${OS}; then
          echo "---> msg: Installing pre-regs for Ubuntu ${OS}"
	  iost_ubuntu_options
      elif echo ${DEBIAN_MANDATORY[@]} | grep -q -w ${OS}; then
          echo "---> msg: Installing pre-regs for Debian ${OS}"
      else 
	  echo "---> msg: ERROR: appear to be running Linux ${OS}, but not a supported platform"
	  exit 96
      fi

      ;;
    'FreeBSD' )
      OS='FreeBSD'
      alias ls='ls -G'
      ;;
    'WindowsNT' )
      OS='Windows'
      ;;
    'Darwin' )
      OS='Mac'
      ;;
    'SunOS' )
      OS='Solaris'
      ;;
    'AIX' ) 
      OS='AIX'
      ;;
    *) 
     OS='No Clue'	    
    ;;
  esac

  echo "OS: $OS"
}

# if this is to be used in the provision section of a Vagrantfile then
# skipp all the input and "sudo" check
#if [ $FOR_VAGRANT = 1 ]; then
#fi
#clear
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
  echo "  3.  The log file will be located:  $LOG "
  echo ""; echo "";


  echo "This script will install the following:"; echo ""
  echo "  -  Security updates and patches for $UBUNTU_MANDATORY"
  echo "  -  Rocks DB $ROCKSDB_MANDATORY"
  echo "  -  Golang verson $GOLANG_MANDATORY"
  echo "  -  nvm version $NVM_MANDATORY"
  echo "  -  node version $NODE_MANDATORY"
  echo "  -  npm version $NPM_MANDATORY"
  echo "  -  docker version $DOCKER_MANDATORY"
  echo "  -  nvm version $NVM_MANDATORY"
  echo "  -  Many packages; software-properties-common, build-essential, curl, git, git-lfs, and more"
  echo ''

  #echo '\n\n'
  #echo 'First we need to confirm that you are not running as "root" and that you can "sudo" to root.\n'
  #echo '\n'

  echo "Make a selection?  (Y/n): "
  read -r CONT

  # if [ -n "$CONT" ]; then
  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ]; then
      echo ""; echo ""
      echo "Good choice, best if you do not install unless you meet the above requirements."
      echo "We know you don't give up that easy, so you will be back."
      echo ""; 
      echo ""
      exit 99
    fi
  fi

  if [[ $(whoami) == "root" ]]; then
      echo 'WARNING:  We are not kidding, you should not run this as the \"root\" user. Modify the sudoers'
      echo 'file with visudo.  Once in the editor, add the following to the bottom of the /etc/sudoers file'
      echo 'non-root user:'
      echo 'NON-ROOT-USER ALL=(ALL) NOPASSWD:ALL'
      exit 96
  fi

}

#
#  iost_detect_vm() - 
#
iost_detect_vm() {
  # are we running in a virtual environment?

  echo "iost_detec_vm"

}

#
#  iost_sudo_confirm () - 
#
iost_sudo_confirm () {

  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#--------------------     IOST Install - packages       -------------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo ''; echo ''

  #
  #  support for a wider number Ubuntu releases (16.04, 16.10, 18.04, and 18.10)
  #

  ###declare -a versions=('xenial' 'yakkety', 'bionic', 'cosmic');
  # check the version and extract codename of ubuntu if release codename not provided by user
  #if [ -z "$1" ]; then
  #    source /etc/lsb-release || \
  #        (echo "Error: Release information not found, run script passing Ubuntu version codename as a parameter"; exit 1)
  #    OS=${DISTRIB_CODENAME}
  #else
  #    OS=${1}
  #fi

  # check version is supported
  #if echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${OS}; then
  #    echo "---> msg: Installing pre-regs for Ubuntu ${OS}"
  #else
  #    echo "---> msg: ERROR: Ubuntu ${OS} is not supported"
  #    exit 1
  #fi


}



#
#  iost_install_packages () - 
#
iost_install_packages () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#------------------     IOST Install - installing packages   --------------=#' 
  echo '#=-------------------------------------------------------------------------=#'

  echo '---> msg: start: iost_install_packages()'
  echo '---> run: apt-get update'
  sudo apt-get update >> $LOG 2>&1

  echo '---> run: apt-get upgrade -y'
  sudo apt-get upgrade -y   >> $LOG 2>&1

  echo '---> run: sudo apt-get install software-properties-common build-essential curl git -y'
  sudo apt install software-properties-common build-essential curl git -y  >> $LOG 2>&1
 
  if ! [ -x "$(command -v git)" ]; then
    echo 'ERROR: git is not installed and executable'; 
    exit 98
  else
    echo -n '---> msg: git installed version '
    git --version | cut -f3 -d' ' 2>/dev/null
  fi

  # install Large File Support for git
  echo '---> run: sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash'
  sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash  >> $LOG 2>&1

  echo '---> run: sudo apt install git-lfs'
  sudo apt install git-lfs >> $LOG 2>&1

  echo '---> run: git lfs install'
  git lfs install >> $LOG 2>&1
  echo '---> msg: done: iost_install_packages\(\)'

}



#
#  iost_install_rocksdb () - 
#
iost_install_rocksdb () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=-------------     IOST Install - installing Rocks DB        -------------=#'
  echo '#=-------------------------------------------------------------------------=#'

  echo '---> msg: start: iost_install_rocksdb()' 
  echo '---> run: apt-get update'

  echo "---> run: sudo apt install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y"
  sudo apt install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y  >> $LOG 2>&1

  echo "---> run: git clone -b $ROCKSDB_MANDATORY https://github.com/facebook/rocksdb.git "
  git clone -b "$ROCKSDB_MANDATORY" https://github.com/facebook/rocksdb.git >> $LOG 2>&1
  cd rocksdb  >> $LOG 2>&1
  echo "---> run: make static_lib"
  make static_lib  >> $LOG 2>&1


  echo '---> run: sudo make install-static'
  sudo make install-static >> $LOG 2>&1

  echo '---> msg: done: iost_install_rocksdb()'
}


#
#  iost_install_nvm_node_npm () - 
#
iost_install_nvm_node_npm () {

  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - nvm, node, npm, & yarn  -------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> msg: start: iost_install_nvm_node_npm ()" 
  cd ~
  echo "---> msg: curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash"   >> $LOG 2>&1
  curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash      >> $LOG 2>&1

  echo "export NVM_DIR="$HOME/.nvm""                                        >> ~/.iost_env
  echo "[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh""                   >> ~/.iost_env 
  echo "[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"" >> ~/.iost_env  

  source ~/.iost_env

  echo "---> msg: nvm install $NODE_MANDATORY "
  nvm install $NODE_MANDATORY   >> $LOG 2>&1

  echoh "---> msg: npm i yarn"
  npm i yarn  >> $LOG 2>&1

  echo -n '---> msg: nvm version '
  NVM=$(nvm --version 2>/dev/null)
  if [ -z $NVM ]; then
    echo "error"
    ERR=1
  else
    echo "$NVM"
  fi

  echo -n '---> msg: npm version '
  npm --version 2>/dev/null

  echo -n '---> msg: node version '
  node --version 2>/dev/null

  echo '---> msg: nvm, node, and npm installed'
  echo "---> msg: done: iost_install_nvm_node_npm ()" 
}



#
#  iost_install_docker () - 
#
iost_install_docker () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - Installing Docker    ----------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> msg: start: iost_install_docker ()"

  echo "---> run: sudo apt install apt-transport-https ca-certificates -y >> $LOG 2>&1"
  sudo apt install apt-transport-https ca-certificates -y >> $LOG 2>&1

  echo "---> run: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> $LOG 2>&1

  lsb=$(lsb_release -cs)
  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $lsb stable" | sudo tee /etc/apt/sources.list.d/docker.list  >> $LOG 2>&1

  echo "---> run: sudo apt-get update"
  sudo apt-get update   >> $LOG 2>&1

  echo "---> run: sudo apt-get install docker-ce -y"
  sudo apt-get install docker-ce -y  >> $LOG 2>&1

  # Add user account to the docker group
  echo "---> run: sudo usermod -aG docker $(whoami) "
  sudo usermod -aG docker $(whoami)   >> $LOG 2>&1

  echo -n '---> msg: docker version '
  DOCKER=$(docker --version 2>/dev/null)

  if [ -z $DOCKER ]; then
    echo "error"
    ERR=1
  else
    echo "$DOCKER"
  fi

  echo "---> msg: done: iost_install_docker ()"
}


#
#  iost_install_golang() - 
#
iost_install_golang () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - Installing Golang    ----------------=#'
  echo '#=-------------------------------------------------------------------------=#'

  echo "---> msg: start: iost_install_golang ()"
  readonly IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"
  alias ir="cd $IOST_ROOT"

  # check for logic that sources IOST env file
  if ! $(grep "IOST setup" > /dev/null >&1); then
    echo "---> msg: did not find IOST setup in .bashrc, adding"
    echo "if [ -f ~/.iost_env ]; then" >> ~/.bashrc
    echo "  source ~/.iost_env"        >> ~/.bashrc
    echo "fi"                          >> ~/.bashrc
  else
    echo "---> msg: found IOST setup in .bashrc, will not add"
  fi

  echo "
  #"                               >> ~/.iost_env
  echo "# Start:  IOST setup\n"    >> ~/.iost_env
  echo "#"                         >> ~/.iost_env
  echo "export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost" >> ~/.iost_env
  echo "alias ir=\"cd $IOST_ROOT\"" >> ~/.iost_env

  if [ -f /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz ]; then
    echo "---> msg: removing previous go${GOLANG_MANDATORY}.linux-amd64.tar.gz";
    rm /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz >> $LOG 2>&1
  fi

  cd /tmp && wget https://dl.google.com/go/go1.11.3.linux-amd64.tar.gz    >> $LOG 2>&1
  sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz    >> $LOG 2>&1
  echo "---> msg: export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	  >> ~/.iost_env
  echo "---> msg: export GOPATH=$HOME/go" 			          >> ~/.iost_env
  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  export GOPATH=$HOME/go
  source ~/.iost_env

  echo "---> msg: mkdir -p $GOPATH/src && cd $GOPATH/src"
  mkdir -p $GOPATH/src && cd $GOPATH/src

  echo -n '--> msg: go version '
  GO=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
  echo $GO

  echo "---> msg: done: iost_install_golang ()"
}


#
#  iost_check_deps () - 
#
iost_check_deps () {
  return
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - check out versions   ----------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo ''; echo ''
  ERR=0
  echo 'Installation completed: '; echo '';
  echo -n ' OS:       '
  OS=$(echo $UBUNTU_VERSION | cut -f2 -d'=' 2>/dev/null)
  echo $OS


  #echo -n ' python:   '
  #PYTHON=$(python -V 2>/dev/null)
  #if [ -z $PYTHON ]; then
  #  echo "error"
  #  ERR=1
  #else
  #  echo "$PYTHON"
  #fi


}

#
#  iost_install_iost () - 
#
iost_install_iost () {
  echo ''; echo ''
  
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=--------- IOST Install - go get -d github.com/iost-official/go-iost -----=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> msg: start: iost_install_iost ()"

  ###go get -d github.com/iost-official/go-iost
  ###cd github.com/iost-official/go-iost/

  echo "---> msg: env | grep GO"
  env | grep GO


  echo "---> msg: cd $GOPATH/src"
  cd $GOPATH/src
  echo "---> msg: go get -d github.com/iost-official/go-iost"
  go get -d github.com/iost-official/go-iost

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


iost_install_iwallet () {

  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - build iwallet    --------------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> start: iost_install_iwallet ()"

  ir && cd iwallet/contract
  npm install

  echo "---> end: iost_install_iwallet ()"
}

iost_install_iwallet () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - deploy V8        --------------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> start: iost_install_v8vm()"

  ir && cd vm/v8vm/v8
  make deploy
  echo "---> start: iost_install_v8vm()"
}


iost_install_iserver () {
  echo '#=-------------------------------------------------------------------------=#'
  echo '#=------------------   IOST Install - build iwallet    --------------------=#'
  echo '#=-------------------------------------------------------------------------=#'
  echo "---> start: iost_install_iserver ()"


  #go get -d github.com/iost-official/dapp


  echo "---> end: iost_install_iserver ()"

}


set -e

sudo $(pwd)/data/exit.sh
iost_warning_requirements
iost_os_detect
iost_sudo_confirm
iost_install_packages
#iost_install_rocksdb
iost_install_nvm_node_npm
iost_install_docker
iost_install_golang
#iost_check_deps
iost_install_iost




