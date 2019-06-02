
#          IOST Development Environment

  This script will install all the tools necessary to develop
  smart contracts in JavaScript or interface with the blockchain
  with Go or JavaScript.  Works best in OS containers like LXD/LXC
  or a full VM, but is known to work in Docker as well.  Should
  install all the necessary dependencies and IOST code required
  to be productive in about 15 minutes.

   IOST 3.1.0 Installation:
   -  iwallet
   -  iserver
   -  itest suite
   -  JavaScript SDK
   -  JavaScript example smart contracts
   -  Go SDK
   -  Easy setup for local testnet node

   Distros Supported:
   -  Ubuntu 16.04 (Xenial)
   -  Ubuntu 18.04 (Bionic)

   Dependencies Installed:
   -  apt-transport-https ca-certificates
   -  software-properties-common
   -  build-essential curl git git-lfs
   -  libgflags-dev libsnappy-dev zlib1g-dev
   -  libbz2-dev liblz4-dev libzstd-dev
   -  distro updates
   -  nvm v0.34.0
   -  npm v6.4.2
   -  node v10.15.3
   -  Go 1.12.4

   Admin Menu:
   -  IOST install
   -  IOST removal
   -  iServer start/stop/restart
   -  run iTest suite
   -  run test contract
   -  run JavaScript SDK test
   -  view install log


  #  Build instructions
  ```
  git clone https://github.com/jimoquinn/iost-unofficial
  cd iost-unofficial/scripts
  ./bootstrap.sh
  ```


  #  Admin Menu
  ```
  echo -e ""
  echo -e "    1.  IOST Install development environment"
  echo -e "    2.  IOST Uninstall development environment"
  echo -e ""
  echo -e "    3.  iServer start local node"
  echo -e "    4.  iServer stop local node"
  echo -e "    5.  iServer restart local node"
  echo -e ""
  echo -e "    6.  Test local node status with iWallet"
  echo -e "    7.  Test local node with iTest"
  echo -e "    8.  Test local node status with JavaScript SDK"
  echo -e ""
  echo -e "    9.  dApp run example contract"
  echo -e "   10.  dApp run example contract"
  echo -e ""
  echo -e "   10.  Open the command line interface"
  echo -e "   11.  View last install log"
  echo -e "   12.  View important developer information"
  echo -e ""
  echo -e "   99.  Quit"
  echo -e ""

  ```

