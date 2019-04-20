# iost-unofficial - simplyfing the IOST development ecosystem
bootstrap.sh - for greenfield installs, either bare metal or VM.  This script 
will install all the tools necessary to develop smartcontracts in JavaScript
or Go in the IOST ecosystem.

Distros Supported:
*  Ubuntu 16.04 (Xenial)
*  Ubuntu 17.04 (Yakkity)
*  Ubuntu 18.04 (Bionic)


Dependencies Installed:
* apt-transport-https ca-certificates 
* software-properties-common 
* build-essential curl git git-lfs 
* libgflags-dev libsnappy-dev zlib1g-dev 
* libbz2-dev liblz4-dev libzstd-dev   
* distro updates
* nvm v0.34.0
* npm v6.4.2
* node v10.15.3
* Go 1.12.4


IOST 3.0.9 Installation: 
* iwallet
* iserver
* itest suite
* IOST JavaScript SDK
* IOST Go SDK
* local testnet node


Admin Menu:
* IOST install
* IOST removal
* iserver start/stop/restart
* run itest 
* view install log


#  Build instructions
```
git clone https://github.com/jimoquinn/iost-unofficial
cd iost-unofficial/scripts
./bootstrap.sh
```


