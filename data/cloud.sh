#!/bin/bash

vagrant cloud publish jimoquinn/IOST_v1.0.0 vmware /Users/jimoquinn/Documents/Vagrant/iost-three/package.box -d "Ubuntu 18.04 loaded with IOST's development ecosystem. Golang, RocketDB, Docker, iWallet, iServer, scaf for dapps." --version-description "Initial test push" --release --short-description "IOST + Ubuntu 18.04"

# You are about to create a box on Vagrant Cloud with the following options:
# briancain/supertest (1.0.0) for virtualbox
# Automatic Release:     true
# Box Description:       Ubuntu 18.04 loaded with IOST's development ecosystem; golang, rocketdb, docker, iwallet, iserver, testnet, etc.
# Box Short Description: Ubuntu 18.04 loaded with IOST's development ecosystem;
# Version Description:   Initial test push
# Do you wish to continue? [y/N] y
# 
# Creating a box entry...
# Creating a version entry...
# Creating a provider entry...
# Uploading provider with file /Users/vagrant/boxes/my/virtualbox.box
# Releasing box...
# Complete! Published briancain/supertest
# tag:                  briancain/supertest
# username:             briancain
# name:                 supertest
# private:              false
# downloads:            0
# created_at:           2018-07-25T17:53:04.340Z
# updated_at:           2018-07-25T18:01:10.665Z
# short_description:    Download me!
# description_markdown: A really cool box to download and use
# current_version:      1.0.0
# providers:            virtualbox
