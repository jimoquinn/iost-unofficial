#!/bin/bash



vagrant box add https://iost.black/vagrant/vagrant-lxc-bionic-amd64.box --name iost/vagrant-lxc-bionic-amd64
mkdir -p iost/vagrant-lxc-bionic-amd64
cd iost/vagrant-lxc-bionic-amd64
vagrant init iost/vagrant-lxc-bionic-amd64
vagrant up
