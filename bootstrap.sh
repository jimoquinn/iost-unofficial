#!/bin/bash 

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
#     IOST BaIfS - Build & Install from Source
#
#  This script is intended to be run on a fresh
#  install, not on top of a production or already
#  configured system.  Believe the term is "greenfield",
#  but like "bespoke" and "performant", I tend to 
#  giggle when typing those words so avoid them when
#  possible.  
#
#  Having said that, I've had success restarting the 
#  installation several times with no real consequences
#  except for a messy .profile and .bashrc.
#
#  With the exception of Go and some packages, it will
#  download, compile the source code, and then install
#  IOST and supporting code on the system.  The list is:
# 
#  - updates & patches for Ubuntu 18.04 with apt
#  - git, git-lfs, build-essentials, 
#  - RocksDB
#  - Go 
#  - nvm
#  - npm 
#  - node
#  - docker
#  - IOST from github.com/iost-official/go-iost
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# the version we're looking for
readonly UBUNTU_MANDATORY="Ubuntu 18.04"
readonly ROCKSDB_MANDATORY="v5.14.3"
readonly GOLANG_MANDATORY="1.11.3"
readonly NODE_MANDATORY="v10.14.2"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.33.11"
readonly DOCKER_MANDATORY="v18.06.0-ce"

readonly IOST_MANDATORY=""
readonly IOST_ROOT="$HOME/go/src/github.com/iost-official/go-iost"
alias ir="cd $IOST_ROOT"

echo "

#"  >> ~/.bashrc
echo "# Start:  IOST setup\n" >> ~/.bashrc
echo "#"  >> ~/.bashrc
echo "export IOST_ROOT=$HOME/go/src/github.com/iost-official/go-iost" >> ~/.bashrc
echo "alias ir=\"cd $IOST_ROOT\"" >> ~/.bashrc

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# NO NEED TO MODIFY BELOW THIS LINE
# UNLESS THE BUILD IS TOTALLY BROKEN
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


clear

printf "\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#--------------------     IOST BaIfS - requirements     -------------------=#\n" 
printf  "#=-------------------------------------------------------------------------=#\n\n"
printf "Please read carefully as these are hard requirements:\n\n"
printf "  1.  This is a greenfield install, do not install on a configured system. \n"
printf "  2.  Must install on $UBUNTU_MANDATORY.  This script will confirm the distro and version. \n"
printf "  3.  Do not run as the "root" user.  Run under a user that can sudo to "root" (see visudo).  \n"
printf "\n"; 


printf "Do you want to continue?  (Y/n): "
read CONT

if [ ! -z "$CONT" ]; then
  if [ $CONT == "n" ] || [ $CONT == 'N' ]; then
    printf "\n"
    printf "Good choice, best if you do not install unless you meet the above requirements.\n"
    printf "But, I know you don't give up that easy, so you'll be back.\n"
    printf "\n"; printf "\n"
    exit 99
  fi
fi


printf "\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#--------------------       IOST BaIfS - packages       -------------------=#\n" 
printf  "#=-------------------------------------------------------------------------=#\n\n"
printf "This script will install the following:\n\n"
printf "  1.  The latest updates and patches to $UBUNTU_MANDATORY packages\n"
printf "  2.  Rocks DB $ROCKSDB_MANDATORY\n"
printf "  3.  Golang verson $GOLANG_MANDATORY\n"
printf "  4.  nvm version $NVM_MANDATORY\n"
printf "  5.  node version $NODE_MANDATORY\n"
printf "  6.  npm version $NPM_MANDATORY\n"
printf "  7.  docker version $DOCKER_MANDATORY\n"
printf "  8.  Many packages; software-properties-common, build-essential, curl, git, git-lfs, and more\n"
printf "\n"


printf "Do you want to continue?  (Y/n): "
read CONT
if [ ! -z "$CONT" ]; then
  if [ $CONT == "n" ] || [ $CONT == 'N' ]; then
    printf "Good choice, you may be over your head.  Pools require hard work.\n"
    printf "Bye, but hope to see you again soon.\n"
    printf "\n"; printf "\n"
    exit 99
  fi
fi

printf "\nHere we go....\n"

if [ ! -r /etc/os-release ]
then
  printf "\nCannot read [/etc/os-release] so it appears that you are not running distribution \n[$UBUNTU_MANDATORY].\n"
  printf "Do hou want to continue? (Y/n): "
  read CONT
  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ]; then
      printf "\nBecause we can't read /etc/os-release we are exiting the installation.\n" 
      exit 98
    fi
  fi
fi


# 2018/12/25 - implement code that supports multiple versions
# /etc/os-release is in good shape, lets check it out.  We check out only the major and
# minor versions, not the point release.
readonly UBUNTU_VERSION=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | grep "$UBUNTU_MANDATORY" 2>/dev/null)
readonly UBUNTU_DISPLAY=$(echo $UBUNTU_VERSION | cut -f2 -d'=' 2>/dev/null)

if [ "$UBUNTU_VERSION" ==  "" ] 
then
  printf "Appears that you are running distribution [$UBUNTU_VERSION] which is not [$UBUNTU_MANDATORY]. \nDo you want to continue? (Y/n):"
  read CONT
  if [ ! -z "$CONT" ]; then
    if [ $CONT == "n" ] || [ $CONT == 'N' ]; then
      printf "Good choice, best not install unless you are running Linux distribution [$UBUNTU_MANDATORY].\n";
      exit 97
    fi
  fi
else
  printf "\nGood news, you are running Linux distribution [$UBUNTU_MANDATORY], specifically [$UBUNTU_DISPLAY]. \n"
  printf "Continuning the installation in 5 seconds...\n\n"
  sleep 8
fi

if [[ $(whoami) == "root" ]]; then
    printf "WARNING:  We are not kidding, you should not run this as the \"root\" user. Modify the sudoers\n"
    printf "file with visudo.  Once in the editor, add the following to the bottom of the /etc/sudoers file \n"
    printf "non-root user:\n\n"
    printf "NON-ROOT-USER ALL=(ALL) NOPASSWD:ALL\n\n"
    exit 96
fi



printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#------------------     IOST BaIfS - installing packages ------------------=#\n" 
printf  "#=-------------------------------------------------------------------------=#\n"

sudo apt install software-properties-common build-essential curl git -y
sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install git-lfs
git lfs install
echo "Done with updates, patches, packages, git, curl and git-lfs\n\n"



printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=-------------     IOST BaIfS - installing Rocks DB        ---------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"

sudo apt install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev -y
git clone -b "$ROCKSDB_MANDATORY" https://github.com/facebook/rocksdb.git && cd rocksdb && make static_lib 
sudo make install-static
cd ~
echo "Done with rocksdb install\n\n"



printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - nvm, node, and npm   ------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install $NODE_MANDATORY
echo "Done with nvm, node, and npm install\n\n"



printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - Installing Docker    ------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"
sudo apt install apt-transport-https ca-certificates -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs)  \
stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update

# Verifies APT is pulling from the correct Repository
#sudo apt-cache policy docker-ce

sudo apt-get install docker-ce -y

# Add user account to the docker group
sudo usermod -aG docker $(whoami)
echo "Done with Docker install\n\n"


printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - Installing Golang    ------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"


cd /tmp && wget https://dl.google.com/go/go1.11.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.3.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" 	    >> ~/.bashrc
echo "export GOPATH=$HOME/go" 			                    >> ~/.bashrc
source ~/.bashrc
mkdir -p $GOPATH/src && cd $GOPATH/src
echo "Done with Golang install\n\n"


printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - check out versions   ------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"
printf "\n\n";
ERR=0
printf "Installation completed: \n\n";
echo -n ' OS:       '
OS=$(echo $UBUNTU_VERSION | cut -f2 -d'=' 2>/dev/null)
echo $OS

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

echo -n '     go:   '
GO=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
echo $GO

echo -n ' docker:   '
DOCKER=$(docker --version 2>/dev/null)
if [ -z $DOCKER ]; then
	echo "error"
	ERR=1
else
	echo "$DOCKER"
fi

echo -n ' python:   '
PYTHON=$(python -V 2>/dev/null)
if [ -z $PYTHON ]; then
	echo "error"
	ERR=1
else
	echo "$PYTHON"
fi

echo -n '   git:    '
git --version | cut -f3 -d' ' 2>/dev/null


if [ $ERR == 1 ]; then
  echo "error:  there was an error installing dependencies"
  exit;
fi

printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=--------- IOST BaIfS - go get -d github.com/iost-official/go-iost -------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"

go get -d github.com/iost-official/go-iost
cd github.com/iost-official/go-iost/


printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - build iwallet    ----------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"

ir && cd iwallet/contract
npm install

printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - deploy V8        ----------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"

ir && cd vm/v8vm/v8
make deploy

printf  "\n\n"
printf  "#=-------------------------------------------------------------------------=#\n"
printf  "#=------------------   IOST BaIfS - build iwallet    ----------------------=#\n"
printf  "#=-------------------------------------------------------------------------=#\n\n"


#go get -d github.com/iost-official/dapp


printf  "#=-------------------------------------------------------------------------=#\n"



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

