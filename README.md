
#          IOST Development Environment

  This script will install all the tools necessary to develop 
  smartcontracts in JavaScript or Go in the IOST ecosystem.
  Works best in OS containers like LXD/LXC or a full VM, but
  is know to work in Docker as well.  Should install all the 
  necessary dependecies and IOST code required to be productive 
  in about 15 minutes.

   IOST 3.1.0 Installation:
   -  iwallet
   -  iserver
   -  itest suite
   -  JavaScript SDK
   -  JavaScript example smart contracts
   -  Go SDK
   -  easy setup for local testnet node

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
   -  run iTest
   -  view install log  


  #  Build instructions
  ```
  git clone https://github.com/jimoquinn/iost-unofficial
  cd iost-unofficial/scripts
  ./bootstrap.sh
  ```


  #  Admin Menu
  ```
  #=--------------------------------------------------=#
  #=--        IOST Install/Test/Admin Script        --=#
  #=--  https://github.com/iost-official/go-iost    --=#
  #=--        Codebase Version: 3.1.0               --=#
  #=--------------------------------------------------=#

    1.  IOST Install development environment
    2.  IOST Uninstall development environment

    3.  iServer start local node
    4.  iServer stop local node
    5.  iServer restart local node

    6.  Test iWallet by checking node status
    7.  Test blockchain with iTest
    8.  Test JavaScript SDK

    9.  Open the command line interface
   10.  View last install log
   11.  View important developer information

   99.  Quit

  Select a number:
  ```

