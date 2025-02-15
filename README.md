[ I am no longer involved with IOST, for several years now, so archiving ]

#          IOST Development Environment

  This script will install all the tools necessary to develop
  smart contracts in JavaScript or interface with the blockchain
  with Go or JavaScript.  Works best in OS containers like LXD/LXC
  or a full VM, but is known to work in Docker as well.  Should
  install all the necessary dependencies and IOST code required
  to be productive in about 15 minutes.

   IOST 3.1.1 Installation:
   -  Easy setup for local testnet node
   -  iwallet
   -  iserver
   -  itest suite
   -  JavaScript SDK
   -  JavaScript example blockchain code
   -  JavaScript example dApp code
   -  Go SDK

   Distros Supported:
   -  Ubuntu 16.04 (Xenial)
   -  Ubuntu 18.04 (Bionic)
   -  Ubuntu 18.10 (Cosmic)

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
   -  run JavaScript SDK test
   -  run blockchain test 
   -  run dapp smart contract
   -  view install log


  #  Build instructions
  ```
  git clone https://github.com/jimoquinn/iost-unofficial
  cd iost-unofficial/scripts
  ./bootstrap.sh
  ```


  #  Admin Menu
  ```

    1.  IOST Install development environment
    2.  IOST Uninstall development environment

    3.  iServer start local node
    4.  iServer stop local node
    5.  iServer restart local node

    6.  Test local node status with iWallet
    7.  Test local node with iTest
    8.  Test local node status with JavaScript SDK

    9.  dApp run example contract

   10.  Open the command line interface
   11.  View last install log
   12.  View important developer information

   99.  Quit"


  ```

