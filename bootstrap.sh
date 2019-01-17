#!/bin/bash 

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
#           IOST "One Click" Development Environment
#            For Greenfield Ubuntu Installation
#
#
#  Objective:  to provide a single script that will install
#  all the necessary dependecies and IOST code required to be
#  productive in less than 15 minutes.  No need waste time 
#  installing a dozen packages by hand all while unsure if they 
#  are the correct versions.
#
#  When the install finishes, you can develop dApps, use iWallet, 
#  run a node with iServer, 
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
#  - scaf - dApp development tool
#
#  Report bugs to:
#  https://github.com/jimoquinn/iost-unofficial
#
#  You can contact me here:
#  jim.oquinn@gmail.com
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# set to 1 if you'd like to clean up previous install attempts
readonly IOST_CLEAN_INSTALL="1"

# you can hardcode the distro and 
DIST=""
CODE=""
pkg_installer=''



# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# the version we're looking for

# package.io not supported on cosmic yet
#readonly UBUNTU_MANDATORY=('xenial' 'yakkety' 'bionic');
readonly UBUNTU_MANDATORY=('16.04' '16.10' '18.04');
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
iost_install_init () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - pre-init      -------------------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_init () "

  # 1st - confirm that we are not running under root
  if [[ $(whoami) == "root" ]]; then
      echo 'WARNING:  We are not kidding, you should not run this as the "root" user. Modify the sudoers'
      echo 'file with visudo.  Once in the editor, add the following to the bottom of the file.  Be sure '
      echo 'to replace NON-ROOT_USER with your actual user id (run "whoami" at the command prompt).'
      echo ''
      echo 'NON-ROOT-USER ALL=(ALL:ALL) ALL'
      echo ''
      exit 99
  fi

  # 2nd - test if we can sudo 
  sudo $(pwd)/data/exit.sh


  # 3rd - for installed apps
  # check for: 
  # - Ubuntu: 16.04, 16.10, 18.04
  # - Debian: 9.1-6, 10
  # - CentOS: 7.0-6
  # -  MacOS: 14.0.0-2
  # -    Win: 10, Server 2016-2019

  echo "---> msg: determining distributino and release"
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
      echo "---> err: Neiher distribution nor release were not hardcoded at the top of this script" 
      echo "---> err: This is an unsupported distribution and/or version" 
      echo "---> err: Exiting install script"
      exit 98
    fi
  fi


  # pick the installer based off distribution
  if [ -n "$DIST" ]; then
    DIST=${DIST,,}
    echo "---> msg: determining package installer for [$PRETTY_NAME]"
      case "$DIST" in

        centos|rhel)
          pkg_installer="/usr/bin/yum -y "
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
            # setup packages-ubuntu.txt
            echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo "---> err: [$VERSION_ID] [${UBUNTU_MANDATORY[@]}] [${PRETTY_NAME}] is not supported, view $LOG"
            exit 76
          fi
          ;;

        *)
          echo "---> err: the package installer for [$PRETTY_INSTALLER] is unsupported, view $LOG"
          exit 95
          ;;

        esac

        #if [ ! -x "$pkg_installer" ]; then
        #  echo "---> err: the [$pkg_installer] for [$PRETTY_NAME] is not executable, view $LOG"
        #  exit 94
        #fi
  fi




  # TODO: check for installed apps
  # 4th - for installed apps
  # check for: 
  # -  apt: git, git-lfs, software-properties-common, build-essential, curl,
  #    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev 
  # -  rocksdb, nvm, node, npm, yarn, docker, golang, 
  # -  IOST: iwallet, iserver, scaf, 

  echo "---> msg: done: iost_install_init () "
	
}


#
# 
#
iost_install_rmfr () {
  # remove:
  # -  apt: git, git-lfs, software-properties-common, build-essential, curl,
  #    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev 
  #    docker
  # -  rocksdb, nvm, node, npm, yarn, golang, 
  # -  IOST: iwallet, iserver, scaf, 

  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - removing previous install  ------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_rmfr () "

  echo "---> msg: sudo $pkg_installer purge docker-ce libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev  -y"
  sudo $pkg_installer purge docker-ce libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev  -y  >> $LOG 2>&1


  echo "---> msg: $pkg_installer purge git git-lfs software-properties-common  build-essential curl  -y" 
  sudo $pkg_installer purge git git-lfs software-properties-common  build-essential curl  -y  >> $LOG 2>&1

  echo "---> msg: sudo $pkg_installer purge install apt-transport-https -y "
  sudo $pkg_installer purge apt-transport-https -y   >> $LOG 2>&1

  echo "---> msg: sudo $pkg_installer autoremove -y " 
  sudo $pkg_installer autoremove -y    >> $LOG 2>&1

   if [ -f "$HOME/.iost_env" ]; then
     echo "---> msg: rm -fr $HOME/.iost_env"
     rm -fr $HOME/.iost_env
   fi

   if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
     echo "---> run: sudo rm -fr /etc/apt/sources.list.d/docker.list" 
     sudo rm -fr /etc/apt/sources.list.d/docker.list
   fi

   if [ -f "$HOME/.nvm" ]; then
     echo "---> run: rm -fr $HOME/.nvm" 
     rm -fr $HOME/.nvm
   fi

   LOC=$(pwd)
   echo "ROCKSDB: $LOC/rocksdb"

   if [ -d "$LOC/rocksdb" ]; then
     echo "---> run: rm -fr $LOC/rocksdb" 
     rm -fr $LOC/rocksdb
   fi


  echo "---> msg: done: iost_install_init () "

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
#  TODO: iost_ubuntu_options () 
#  - VM/Container options for Ubuntu
#  - create one for each of the supported OSs
#
iost_ubuntu_options () {
  echo 'This script can install IOST with the following:'
  echo "  1.  Greenfield (aka; bare metal fresh install)"
  echo '  2.  Vagrant and LXC '
  echo '  3.  Vagrant and VirtualBox'
  echo '  4.  Kubernetes and Docker'
  echo '  5.  Docker only'
  echo '  6.  VMware only'
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

  echo -e "Make a selection?  (Y/n): "
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


}

#
#  TODO: 
#  iost_detect_vm() - 
#
iost_detect_vm() {
  # are we running in a virtual environment?

  echo "iost_detec_vm"

}

#
#  TODO: 
#  iost_sudo_confirm () - 
#
iost_sudo_confirm () {

  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#--------------------     IOST Install - packages       -------------------=#'
  echo '#=-------------------------------------------------------------------------=#'

}



#
#  iost_install_packages () - 
#
iost_install_packages () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#------------------     IOST Install - installing packages   --------------=#' 
  echo '#=-------------------------------------------------------------------------=#'

  echo "---> msg: start: iost_install_packages()"
  echo "---> run: $pkg_installer install apt-transport-https ca-certificates -y"
  sudo $pkg_installer install apt-transport-https ca-certificates -y >> $LOG 2>&1

  echo "---> run: $pkg_installer update"
  sudo $pkg_installer update >> $LOG 2>&1

  echo "---> run: $pkg_installer upgrade -y"
  sudo $pkg_installer upgrade -y   >> $LOG 2>&1


  echo "---> run: sudo $pkg_installer install software-properties-common -y"
  sudo $pkg_installer install software-properties-common -y  >> $LOG 2>&1

  echo "---> run: sudo add-apt-repository ppa:git-core/ppa -y"
  sudo add-apt-repository ppa:git-core/ppa -y >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer install build-essential curl git -y"
  sudo $pkg_installer install build-essential curl git -y  >> $LOG 2>&1
 
  if ! [ -x "$(command -v git)" ]; then
    echo '---> err: git is not installed and executable'; 
    exit 98
  else
    echo -n '---> msg: git installed version '
    git --version | cut -f3 -d' ' 2>/dev/null
  fi

  # install Large File Support for git
  echo '---> run: sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash'
  sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash  >> $LOG 2>&1

  echo '---> run: $pkg_installer install git-lfs'
  sudo $pkg_installer install git-lfs >> $LOG 2>&1

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

  echo "---> run: sudo $pkg_installer install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y"
  sudo $pkg_installer install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y  >> $LOG 2>&1

  echo "---> run: git clone -b $ROCKSDB_MANDATORY https://github.com/facebook/rocksdb.git "
  git clone -b "$ROCKSDB_MANDATORY" https://github.com/facebook/rocksdb.git >> $LOG 2>&1
  cd rocksdb  >> $LOG 2>&1
  echo "---> run: make static_lib"
  make static_lib  >> $LOG 2>&1


  echo "---> run: sudo make install-static"
  sudo make install-static >> $LOG 2>&1

  echo "---> msg: done: iost_install_rocksdb()"
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
  cd $HOME
  echo "---> run: curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash"   
  curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash      >> $LOG 2>&1

  echo "export NVM_DIR="$HOME/.nvm""                                        >> ~/.iost_env
  echo "[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh""                   >> ~/.iost_env 
  echo "[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"" >> ~/.iost_env  

  echo "---> run: source $HOME/.iost_env"
  source $HOME/.iost_env

  echo "---> run: nvm install $NODE_MANDATORY "
  nvm install $NODE_MANDATORY   >> $LOG 2>&1

  echo "---> run: npm i yarn"
  npm i yarn  >> $LOG 2>&1

  echo -n '---> msg: nvm version '
  NVM_V=$(nvm --version 2>/dev/null)
  if [ -z $NVM_V ]; then
    echo "---> msg: error: nvm install failed, check $LOG"
    ERR=1
  else
    echo "$NVM_V"
  fi

  echo -n '---> msg: npm version '
  npm --version 2>/dev/null
  NPM_V=$(npm --version 2>/dev/null)
  if [ -z $NPM_V]; then
    echo "---> msg: error: npm install failed, check $LOG"
    ERR=1
  else
    echo "$NPM_V"
  fi

  echo -n '---> msg: node version '
  NODE_V=$(node --version 2>/dev/null)
  if [ -z $NODE_V]; then
    echo "---> msg: error: node install failed, check $LOG"
    ERR=1
  else
    echo "$NODE_V"
  fi

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

  echo "---> run: sudo $pkg_installer install apt-transport-https ca-certificates -y >> $LOG 2>&1"
  sudo $pkg_installer install apt-transport-https ca-certificates -y >> $LOG 2>&1

  echo "---> run: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> $LOG 2>&1

  lsb=$(lsb_release -cs)
  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $lsb stable" | sudo tee /etc/apt/sources.list.d/docker.list  >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer update"
  sudo $pkg_installer update                >> $LOG 2>&1

  echo "---> run: sudo $pkg_installer install docker-ce -y"
  sudo $pkg_installer install docker-ce -y  >> $LOG 2>&1

  # Add user account to the docker group
  echo "---> run: sudo usermod -aG docker $(whoami) "
  sudo usermod -aG docker $(whoami)         >> $LOG 2>&1

  echo -n '---> msg: docker version '
  DOCKER_V=$(docker version 2>/dev/null)
  if [ -z $DOCKER_V ]; then
    echo "---> msg: error: docker install failed, check $LOG"
    ERR=1
  else
    echo "$DOCKER_V"
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
  CHK_SETUP=$(grep "IOST setup" $HOME/.bashrc > /dev/null >&1)  
  if [ -z "$CHK_SETUP" ]; then 
    echo "---> msg: did not find IOST setup in .bashrc, adding"
    echo "if [ -f "$HOME/.iost_env" ]; then" >> $HOME/.bashrc
    echo "  source $HOME/.iost_env"          >> $HOME/.bashrc
    echo "fi"                                >> $HOME/.bashrc
  else
    echo "---> msg: found IOST setup in [$HOME/.bashrc], will not add"
  fi

  echo "
  #"                               >> $HOME/.iost_env
  echo "# Start:  IOST setup\n"    >> $HOME/.iost_env
  echo "#"                         >> $HOME/.iost_env
  echo "export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost"                >> $HOME/.iost_env
  echo "alias ir=\"cd $IOST_ROOT\""                                                    >> $HOME/.iost_env

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

  echo "---> run: mkdir -p $GOPATH/src && cd $GOPATH/src"
  mkdir -p $GOPATH/src && cd $GOPATH/src

  echo -n '--> msg: go version '
  GO_V=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
  if [ -z $GO_V]; then
    echo "---> msg: error: $GOLANG_MANDATORY install failed, check $LOG"
    ERR=1
  else
    echo "$GO_V"
  fi

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


if [ -f "$HOME/.iost_env" ]; then
  iost_install_rmfr
fi


iost_install_init
iost_warning_requirements
iost_install_packages
iost_install_rocksdb
iost_install_nvm_node_npm
iost_install_docker
iost_install_golang
#iost_check_deps
iost_install_iost




  # This script can install the following:'
  #  1.  Linux: Vagrant   LXC         Ubuntu 19.04 (Disco Dingo)'
  #  1.  Linux: Vagrant   LXC         Ubuntu 18.10 (Cosmic Cuttlefish)'
  #  2.  Linux: Vagrant   LXC         Ubuntu 18.04 (Bionic Beaver)'
  #  3.  Linux: Vagrant   LXC         Ubuntu 16.10 (Yakkety Yak)'
  #  4.  Linux: Vagrant   LXC         Ubuntu 16.04 (Xenial Xerus)'
  #  5.  Linux: Vagrant   LXC         CentOS 7 '
  #  6.  Linux: Vagrant   LXC         Debian Stretch 9'

  #  7.  Linux: Vagrant   VMware      Ubuntu 19.04 (Disco Dingo)'
  #  8.  Linux: Vagrant   VMware      Ubuntu 18.10 (Cosmic Cuttlefh)'
  #  9.  Linux: Vagrant   VMware      Ubuntu 18.04 (Bionic Beaver)'
  # 10.  Linux: Vagrant   VMware      Ubuntu 16.10 (Yakkety Yak)'
  # 11.  Linux: Vagrant   VMware      Ubuntu 16.04 (Xenial Xerus)'
  # 12.  Linux: Vagrant   VMware      CentOS 7' 
  # 13.  Linux: Vagrant   VMware      Debian Stretch 7' 

  # 14.  Linux: Vagrant   VirtualBox  Ubuntu 19.04 (Disco Dingo)'
  # 14.  Linux: Vagrant   VirtualBox  Ubuntu 18.04 (Bionic Beaver)'
  # 15.  Linux: Vagrant   VirtualBox  Ubuntu 18.10 (Cosmic Cuttlefish)'
  # 16.  Linux: Vagrant   VirtualBox  Ubuntu 18.04 (Bionic)'
  # 17.  Linux: Vagrant   VirtualBox  Ubuntu 16.04 (Bionic)'
  # 18.  Linux: Vagrant   VirtualBox  Ubuntu 16.04 (Xenial Xerus)'
  # 19.  Linux: Vagrant   VirtualBox  CentOS 7.0-7.6' 
  # 20.  Linux: Vagrant   VirtualBox  Debian Stretch 9.0-9.6'
  # 20.  Linux: Vagrant   VirtualBox  Debian Buster 10.0'

  # 24.  Linux: Kubernetes Docker     Ubuntu 19.04 (Disco Dingo)'
  # 21.  Linux: Kubernetes Docker     Ubuntu 18.10 (Cosmic Cuttlefish
  # 22.  Linux: Kubernetes Docker     Ubuntu 18.04 (Bionic Beaver)'
  # 23.  Linux: Kubernetes Docker     Ubuntu 16.04 (Bionic)'
  # 24.  Linux: Kubernetes Docker     Ubuntu 16.04 (Xenial Xerus)'
  # 25.  Linux: Kubernetes Docker     CentOS 7.0-7.6 '
  # 26.  Linux: Kubernetes Docker     Debian 10.0     (Buster)'
  # 26.  Linux: Kubernetes Docker     Debian 9.0-9.6' (Stretch)

  # 24.  Linux: Docker only           Ubuntu 19.04 (Disco Dingo)'
  # 21.  Linux: Docker only           Ubuntu 18.10 (Cosmic Cuttlefish
  # 22.  Linux: Docker only           Ubuntu 18.04 (Bionic Beaver)'
  # 23.  Linux: Docker only           Ubuntu 16.04 (Bionic)'
  # 24.  Linux: Docker only           Ubuntu 16.04 (Xenial Xerus)'
  # 25.  Linux: Docker only           CentOS 7.0-7.6 '
  # 26.  Linux: Docker only           Debian 10.0     (Buster)'
  # 26.  Linux: Docker only           Debian 9.0-9.6' (Stretch)

  # 24.  Linux: VMware only           Ubuntu 19.04 (Disco Dingo)'
  # 21.  Linux: VMware only           Ubuntu 18.10 (Cosmic Cuttlefish
  # 22.  Linux: VMware only           Ubuntu 18.04 (Bionic Beaver)'
  # 23.  Linux: VMware only           Ubuntu 16.04 (Bionic)'
  # 24.  Linux: VMware only           Ubuntu 16.04 (Xenial Xerus)'
  # 25.  Linux: VMware only           CentOS 7.0-7.6 '
  # 26.  Linux: VMware only           Debian 10.0     (Buster)'
  # 26.  Linux: VMware only           Debian 9.0-9.6' (Stretch)
