#!/bin/bash -x


# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# MODIFY VERSIONS ONLY IF NECESSARY
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# readonly
readonly IOST_RELEASE="3.0.4"

# package.io not supported on cosmic yet
# 'xenial' 'yakkety' 'bionic', 'linuxmint'
readonly UBUNTU_MANDATORY=('16.04' '16.10' '18.04', '19');  
readonly CENTOS_MANDATORY=('centos7');
readonly DEBIAN_MANDATORY=('stretch');
readonly MACOS_MANDATORY=('Darwin', 'Hitchens');

readonly GOLANG_MANDATORY="1.11.3"
readonly NODE_MANDATORY="v10.14.2"
readonly NPM_MANDATORY="v6.4.1"
readonly NVM_MANDATORY="v0.34.0"

# install and blockchain logs
readonly SERVER_LOG="/tmp/bootstrap.sh.$$.log"



#
#
#
iost_install_init () {
  clear
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#-----------------   IOST Install - pre-init      -------------------------=#"
  echo "#=-------------------------------------------------------------------------=#"
  echo "---> msg: start: iost_install_init () " | tee -a $SERVER_LOG

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


  # 3rd - for installed apps
  # check for:
  # - Ubuntu: 16.04, 16.10, 18.04
  # - Debian: 9.1-6, 10
  # - CentOS: 7.0-6
  # -   Mint: 19
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
      case $DIST in

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
            echo "---> err: [$VERSION_ID] [${PRETTY_NAME}] is not supported, view $SERVER_LOG"
            exit 77
          fi
          ;;
        ubuntu|linuxmint)
            if echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${VERSION_ID}; then
            pkg_installer="/usr/bin/apt-get -y "
            pkg_purge=" purge "
            pkg_yes=" -y "
            git_lfs="curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
            dev_tools="$pkg_installer software-properties-common  build-essential"
            # setup packages-ubuntu.txt
            echo "---> msg: [$PRETTY_NAME] is supported and using [$pkg_installer]"
          else
            echo "---> err: [$PRETTY_NAME] is not supported, view $SERVER_LOG"
            exit 76
          fi
          ;;

        *)
          echo "---> err: the package installer for [$PRETTY_INSTALLER] is unsupported, view $SERVER_LOG"
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
    sudo $pkg_installer install git  >> $SERVER_LOG 2>&1
  else
    mygit=$(git --version 2>/dev/null)
    echo "---> msg: $mygit already installed"
  fi


  #
  #  unset any variables
  #
  unset $NVM_DIR


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

  echo "---> msg: done: iost_install_init () " | tee -a $SERVER_LOG

}



#
#  iost_install_packages () -
#
iost_install_packages () {
  echo ''; echo ''
  echo '#=-------------------------------------------------------------------------=#'
  echo '#------------------     IOST Install - installing packages   --------------=#'
  echo '#=-------------------------------------------------------------------------=#'

  echo "---> msg: start: iost_install_packages()" | tee -a $SERVER_LOG

  #$sec_updt=$($pkg_installer list --upgradable | grep security | wc -l)
  #$reg_updt=$($pkg_installer list --upgradable | wc -l)

  echo "---> run: sudo $pkg_installer install apt-transport-https ca-certificates "
  sudo $pkg_installer install apt-transport-https ca-certificates  >> $SERVER_LOG 2>&1

  #echo "---> msg: $sec_updt security udpates and $reg_updt regular updates needed"
  #if (( $reg_updt >= 25 )); then
  #  echo "---> msg: NOTE: given the large number if updagtes, this may take a while"
  #fi


  echo "---> run: sudo $pkg_installer update"
  sudo $pkg_installer update                               >> $SERVER_LOG 2>&1

  echo "---> run: sudo $pkg_installer upgrade "
  sudo $pkg_installer upgrade                              >> $SERVER_LOG 2>&1

  echo "---> run: sudo $pkg_installer install software-properties-common "
  sudo $pkg_installer install software-properties-common   >> $SERVER_LOG 2>&1

  echo "---> run: sudo $dev_tools"
  sudo $dev_tools                                          >> $INSTALL_LOG 2>&1

  echo "---> run: sudo $pkg_installer install build-essential curl git "
  sudo $pkg_installer install build-essential curl git     >> $INSTALL_LOG 2>&1

  echo "---> run: apt-get install gcc-multilib gcc-mingw-w64 mingw-w64-tools libnpth-mingw-w64-dev libssl-dev gdb-mingw-w64 gdb-mingw-w64-target libconfig++-dbg libconfig++-dev libconfig++9v5 libconfig-dbg libconfig-dev libconfig-doc libconfig9 libz-mingw-w64 libz-mingw-w64-dev mingw-ocaml -y"
  sudo $pkg_installer install gcc-multilib gcc-mingw-w64 mingw-w64-tools libnpth-mingw-w64-dev libssl-dev gdb-mingw-w64 gdb-mingw-w64-target libconfig++-dbg libconfig++-dev libconfig++9v5 libconfig-dbg libconfig-dev libconfig-doc libconfig9 libz-mingw-w64 libz-mingw-w64-dev mingw-ocaml -y

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
#  iost_install_golang() -
#
iost_install_golang () {
  echo ""; echo ""
  echo "#=-------------------------------------------------------------------------=#"
  echo "#=------------------   IOST Install - Installing Golang    ----------------=#"
  echo "#=-------------------------------------------------------------------------=#"

  echo "---> msg: start: iost_install_golang ()" | tee -a $SERVER_LOG
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
    rm -fr /tmp/go${GOLANG_MANDATORY}.linux-amd64.tar.gz                               >> $SERVER_LOG 2>&1
  fi

  echo "---> run: cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  cd /tmp && wget https://dl.google.com/go/go${GOLANG_MANDATORY}.linux-amd64.tar.gz    >> $SERVER_LOG 2>&1

  echo "---> run: sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf go${GOLANG_MANDATORY}.linux-amd64.tar.gz                 >> $SERVER_LOG 2>&1

  echo "---> run: export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin"                    >> $SERVER_LOG 2>&1
  echo "---> run: export GOPATH=$HOME/go"                                              >> $SERVER_LOG 2>&1

  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin"                              >> $HOME/.iost_env
  echo "export GOPATH=$HOME/go"                                                        >> $HOME/.iost_env

  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  export GOPATH=$HOME/go
  source $HOME/.iost_env
  source $HOME/.bashrc

  echo "---> run: mkdir -p $GOPATH/src && cd $GOPATH/src"
  mkdir -p $GOPATH/src && cd $GOPATH/src

  echo -n '---> msg: go version '
  GO_V=$(go version | cut -f3 -d' ' | sed 's/go//g' 2>/dev/null)
  if [ -z $GO_V ]; then
    echo "---> msg: error: $GOLANG_MANDATORY install failed, check $SERVER_LOG"
    ERR=1
    exit 50
  else
    echo "$GO_V"
  fi

  echo "---> msg: done: iost_install_golang ()" | tee -a $SERVER_LOG
}


iost_install_golang_deps () {

   echo "---> msg: iost_install_golang_deps() "
   echo "---> msg: echo GOPATH: $GOPATH"
   cd $GOPATH

   # mkdir src
   # cd src
   go get github.com/iost-official/go-iost
   go get golang.org/x/crypto/ssh/terminal

   cp ~/iost-unofficial/src/keystore.go  github.com/iost-official/go-iost/iwallet/keystore.go
   #vi github.com/iost-official/go-iost/iwallet/keystore.go
}

#

#2.  It took me a while to find the corresponding option on Linux, so 
#    in case it helps someone else: The package g++-mingw-w64-x86-64 
#    provides two files x86_64-w64-mingw32-g++-win32 and x86_64-w64-mingw32-g++-posix, 
#    and x86_64-w64-mingw32-g++ is aliased to one of them; see 
#    update-alternatives --display x86_64-w64-mingw32-g++. – stewbasic Feb 24 '18 at 4:08
#
#flexdll/xenial 
#
#Required:
#1.  Install Go Lang
#2.  Install the following (figure out what is mandatory)
#
#
#
## no
#GOOS=windows GOARCH=386 CGO_ENABLED=1 CXX_FOR_TARGET=i686-w64-mingw32-g++ CC_FOR_TARGET=i686-w64-mingw32-gcc go build
#
## yes
#CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ GOOS=windows GOARCH=amd64 go build -o kubeapps.exe .


package="/home/vagrant/"
if [[ -z "$package" ]]; then
  echo "usage: $0 <package-name>"
  exit 1
fi
package_split=(${package//\// })
package_name=${package_split[-1]}

#platforms=("windows/amd64" "windows/386" "darwin/amd64")

platforms=("windows/amd64")

iost_install_init 
iost_install_packages

echo "install golang----------"
iost_install_golang
echo "install golang----------"
iost_install_golang_deps
iost_install_iost
 

for platform in "${platforms[@]}"
do

   

    platform_split=(${platform//\// })
    GOOS=${platform_split[0]}
    GOARCH=${platform_split[1]}
    CGO_ENABLED="1"
    GCC="/usr/bin/x86_64-w64-mingw32-gcc"
    GCC="/usr/bin/x86_64-w64-mingw32-gcc"
    CGO_LDFLAGS="-L/usr/local/ssl/lib"
    output_name=$package_name'-'$GOOS'-'$GOARCH
    if [ $GOOS = "windows" ]; then
        output_name+='.exe'
    fi  

    env GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED="1"  CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CXX_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-g++" CC_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-gcc" CGO_LDFLAGS="-L/usr/local/ssl/lib" CGO_CFLAGS="-I/usr/local/ssl/include" -std="c++11" go build -o $output_name $package
    if [ $? -ne 0 ]; then
        echo 'An error has occurred! Aborting the script execution...'
        exit 1
    fi


    # GOARCH=386 CGO_ENABLED=1 CXX_FOR_TARGET=i686-w64-mingw32-g++ CC_FOR_TARGET=i686-w64-mingw32-gcc    CGO_LDFLAGS="-L/usr/local/ssl/lib -lcrypto -lws2_32 -lgdi32 -lcrypt32" CGO_CFLAGS=-I/usr/local/ssl/include go build
    #env GO_ENABLED=1 CGO_ENABLED="1" CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ GOOS=windows GOARCH=amd64 go build -o $output_name $package
    #env GO_ENABLED=1 GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED="1"  CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CXX_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-g++" CC_FOR_TARGET="/usr/bin/x86_64-w64-mingw32-gcc" CGO_LDFLAGS="-L/usr/local/ssl/lib" CGO_CFLAGS="-I/usr/local/ssl/include" -std="c++11" go build -o $output_name $package

done

