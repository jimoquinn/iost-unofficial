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


# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# the version we're looking for
readonly UBUNTU_MANDATORY=('xenial' 'yakkety', 'bionic', 'cosmic');
readonly CENTOS_MANDATORY=('centos-7');
readonly DEBIAN_MANDATORY=('stretch, ''');
readonly MACOS_MANDATORY=(', ''');

readonly ROCKSDB_MANDATORY="v5.14.3"
readonly GOLANG_MANDATORY="1.11.3"
readonly NODE_MANDATORY="v10.14.2"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.33.11"
readonly DOCKER_MANDATORY="v18.06.0-ce"

readonly IOST_MANDATORY=""
# set to "1" if this is to be used in a Vagrantfile as provision
readonly FOR_VAGRANT="1"	



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




# if this is to be used in the provision section of a Vagrantfile then
# skipp all the input and "sudo" check
#if [ $FOR_VAGRANT = 1 ]; then
#fi
#clear
#
#  iost_warning_requirements () - 
#
iost_warning_requirements () {
  
  printf "\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#-----------------   IOST Install - warning & requirements   --------------=#\n" 
  printf  "#=-------------------------------------------------------------------------=#\n\n"
  printf "Please read carefully as these are hard requirements:\n\n"
  printf "  1.  This is for a greenfield install, do not install on a configured system. \n"
  printf "  2.  Must install on $UBUNTU_MANDATORY.  This script will confirm the distro and version. \n"
  printf "  3.  Do not run as the "root" user.  Run under a user that can sudo to "root" (man visudo).  \n"
  printf "\n\n";
  printf "This script will install the following:\n\n"
  printf "  -  Security updates and patches for $UBUNTU_MANDATORY\n"
  printf "  -  Rocks DB $ROCKSDB_MANDATORY\n"
  printf "  -  Golang verson $GOLANG_MANDATORY\n"
  printf "  -  nvm version $NVM_MANDATORY\n"
  printf "  -  node version $NODE_MANDATORY\n"
  printf "  -  npm version $NPM_MANDATORY\n"
  printf "  -  docker version $DOCKER_MANDATORY\n"
  printf "  -  nvm version $NVM_MANDATORY\n"
  printf "  -  Many packages; software-properties-common, build-essential, curl, git, git-lfs, and more\n"
  printf "\n\n";
  printf "This script can install the following:\n\n"
  printf "  1.  Linux: Vagrant   LXC        Ubuntu 18.10 (Cosmic)\n"
  printf "  2.  Linux: Vagrant   LXC        Ubuntu 18.04 (Bionic)\n"
  printf "  3.  Linux: Vagrant   LXC        Ubuntu 16.04 (Bionic)\n"
  printf "  4.  Linux: Vagrant   LXC        Ubuntu 16.04 (Bionic)\n"
  printf "  5.  Linux: Vagrant   LXC        CentOS 7 \n"
  printf "  6.  Linux: Vagrant   LXC        Debian Stretch 9.\n"
  printf "  7.  Linux: Vagrant   VMware     Ubuntu 18.04 (Bionic)\n"
  printf "  8.  Linux: Vagrant   VMware     Ubuntu 18.10 (Cosmic)\n"
  printf "  9.  Linux: Vagrant   VMware     Ubuntu 18.04 (Bionic)\n"
  printf " 10.  Linux: Vagrant   VMware     Ubuntu 16.04 (Bionic)\n"
  printf " 11.  Linux: Vagrant   VMware     Ubuntu 16.04 (Bionic)\n"
  printf " 12.  Linux: Vagrant   VMware     CentOS 7 \n"
  printf " 13.  Linux: Vagrant   VMware     Debian Stretch 7 \n"
  printf " 14.  Linux: Vagrant   VirtualBox Ubuntu 18.04 (Bionic)\n"
  printf " 15.  Linux: Vagrant   VirtualBox Ubuntu 18.10 (Cosmic)\n"
  printf " 16.  Linux: Vagrant   VirtualBox Ubuntu 18.04 (Bionic)\n"
  printf " 17.  Linux: Vagrant   VirtualBox Ubuntu 16.04 (Bionic)\n"
  printf " 18.  Linux: Vagrant   VirtualBox Ubuntu 16.04 (Bionic)\n"
  printf " 19.  Linux: Vagrant   VirtualBox CentOS 7 \n"
  printf " 20.  Linux: Vagrant   VirtualBox Debian Stretch 7 \n"


  #printf "\n\n";
  #printf "First we need to confirm that you are not running as "root" and that you can "sudo" to root.\n"
  #printf "\n"; 

  printf "Make a selection?  (Y/n): "
  read CONT

  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ]; then
      printf "\n"
      printf "Good choice, best if you do not install unless you meet the above requirements.\n"
      printf "We know you don't give up that easy, so you will be back.\n"
      printf "\n"; printf "\n"
      exit 99
    fi
  fi

  if [[ $(whoami) == "root" ]]; then
      printf "WARNING:  We are not kidding, you should not run this as the \"root\" user. Modify the sudoers\n"
      printf "file with visudo.  Once in the editor, add the following to the bottom of the /etc/sudoers file \n"
      printf "non-root user:\n\n"
      printf "NON-ROOT-USER ALL=(ALL) NOPASSWD:ALL\n\n"
      exit 96
  fi

}

#
#  iost_sudo_confirm () - 
#
iost_sudo_confirm () {

  printf "\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#--------------------     IOST Install - packages       -------------------=#\n" 
  printf  "#=-------------------------------------------------------------------------=#\n\n"
  printf "\n"


  #
  #  support for a wider number Ubuntu releases (16.04, 16.10, 18.04, and 18.10)
  #

  ### Array of supported versions
  ###declare -a versions=('xenial' 'yakkety', 'bionic', 'cosmic');
  # check the version and extract codename of ubuntu if release codename not provided by user
  if [ -z "$1" ]; then
      source /etc/lsb-release || \
          (echo "Error: Release information not found, run script passing Ubuntu version codename as a parameter"; exit 1)
      OS=${DISTRIB_CODENAME}
  else
      OS=${1}
  fi

  # check version is supported
  if echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${OS}; then
      echo "Installing pre-regs for Ubuntu ${OS}"
  else
      echo "Error: Ubuntu ${OS} is not supported"
      exit 1
  fi


}






#
#  iost_install_packages () - 
#
iost_install_packages () {
  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#------------------     IOST Install - installing packages ------------------=#\n" 
  printf  "#=-------------------------------------------------------------------------=#\n"

  printf "---> run: START iost_install_packages() \n";
  printf "---> run: apt-get update\n";
  sudo apt-get update

  printf "---> run: apt-get upgrade\n";
  sudo apt-get upgrade -y

  printf "---> sudo apt-get install software-properties-common build-essential curl git -y\n"
  sudo apt install software-properties-common build-essential curl git -y

  if ! [ -x "$(command -v git)" ]; then
    printf "ERROR:  git is not installed and executable.\n"; 
    exit 98
  else
    echo -n '---> git:    '
    git --version | cut -f3 -d' ' 2>/dev/null
  fi

  # install Large File Support for git
  printf "---> run: sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash\n";
  sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash

  printf "---> run: sudo apt install git-lfs\n";
  sudo apt install git-lfs

  printf "---> run: git lfs install\n";
  git lfs install
  printf "---> run: DONE iost_install_packages() \n";

}



#
#  iost_install_rocksdb () - 
#
iost_install_rocksdb () {
  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=-------------     IOST Install - installing Rocks DB        ---------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"

  printf "---> run: START iost_install_rocksdb() \n";
  printf "---> run: apt-get update\n";

  printf "---> run: sudo apt install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y \n";
  sudo apt install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y

  printf "---> run: git clone -b "$ROCKSDB_MANDATORY" https://github.com/facebook/rocksdb.git && cd rocksdb && make static_lib \n";
  git clone -b "$ROCKSDB_MANDATORY" https://github.com/facebook/rocksdb.git && cd rocksdb && make static_lib 


  printf "---> run: sudo make install-static\n";
  sudo make install-static

  printf "---> run: DONE iost_install_rocksdb() \n";
}


#
#  iost_install_nvm_node_npm () - 
#
iost_install_nvm_node_npm () {

  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - nvm, node, and npm   ------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm install $NODE_MANDATORY


  echo -n '    nvm:   '
  NVM=$(nvm --version 2>/dev/null)
  if [ -z $NVM ]; then
    echo "error"
    ERR=1
  else
    echo "$NVM"
  fi

  echo -n '    npm:   '
  npm --version 2>/dev/null

  echo -n '   node:   '
  node --version 2>/dev/null


  echo "Done with nvm, node, and npm install"
}



#
#  iost_install_docker () - 
#
iost_install_docker () {
  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - Installing Docker    ------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"
  sudo apt install apt-transport-https ca-certificates -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs)  \
  stable" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-get update

  sudo apt-get install docker-ce -y

  # Add user account to the docker group
  sudo usermod -aG docker $(whoami)

  echo -n ' docker:   '
  #DOCKER=$(docker --version 2>/dev/null)
#
#  if [ -z $DOCKER ]; then
#    echo "error"
#    ERR=1
#  else
#    echo "$DOCKER"
#  fi

  echo "Done with Docker install"
}


#
#  iost_install_golang() - 
#
iost_install_golang () {
  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - Installing Golang    ------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"

  readonly IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"
  alias ir="cd $IOST_ROOT"

  echo "

  #"                               >> ~/.bashrc
  echo "# Start:  IOST setup\n"    >> ~/.bashrc
  echo "#"                         >> ~/.bashrc
  echo "export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost" >> ~/.bashrc
  echo "alias ir=\"cd $IOST_ROOT\"" >> ~/.bashrc

  cd /tmp && wget https://dl.google.com/go/go1.11.3.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf go1.11.3.linux-amd64.tar.gz
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	    >> ~/.bashrc
  echo "export GOPATH=$HOME/go" 			            >> ~/.bashrc
  .  ~/.bashrc
  mkdir -p $GOPATH/src && cd $GOPATH/src

  echo -n '     go:   '
  GO=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
  echo $GO

  echo "Done with Golang install"
}


#
#  iost_check_deps () - 
#
iost_check_deps () {
  return
  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - check out versions   ------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"
  printf "\n\n";
  ERR=0
  printf "Installation completed: \n\n";
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
  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=--------- IOST Install - go get -d github.com/iost-official/go-iost -------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"

  go get -d github.com/iost-official/go-iost
  cd github.com/iost-official/go-iost/


  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - build iwallet    ----------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"

  ir && cd iwallet/contract
  npm install

  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - deploy V8        ----------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"

  ir && cd vm/v8vm/v8
  make deploy

  printf  "\n\n"
  printf  "#=-------------------------------------------------------------------------=#\n"
  printf  "#=------------------   IOST Install - build iwallet    ----------------------=#\n"
  printf  "#=-------------------------------------------------------------------------=#\n\n"


  #go get -d github.com/iost-official/dapp


  printf  "#=-------------------------------------------------------------------------=#\n"

}


set -e

iost_warning_requirements
iost_sudo_confirm
iost_install_packages
iost_install_rocksdb
iost_install_nvm_node_npm
iost_install_docker
iost_install_golang
iost_check_deps




























#
#  support for a wider number Ubuntu releases (16.04, 16.10, 18.04, and 18.10)
#  18.10 has k8s, docker, lxc, 
#
### Array of supported versions
###declare -a versions=('xenial' 'yakkety', 'bionic');
##### check the version and extract codename of ubuntu if release codename not provided by user
####if [ -z "$1" ]; then
####    source /etc/lsb-release || \
####        (echo "Error: Release information not found, run script passing Ubuntu version codename as a parameter"; exit 1)
####    CODENAME=${DISTRIB_CODENAME}
####else
####    CODENAME=${1}
####fi
####
##### check version is supported
####if echo ${versions[@]} | grep -q -w ${CODENAME}; then
####    echo "Installing Hyperledger Composer prereqs for Ubuntu ${CODENAME}"
####else
####    echo "Error: Ubuntu ${CODENAME} is not supported"
####    exit 1
####fi
####
###exit;

