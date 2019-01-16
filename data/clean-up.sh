#!/bin/bash

do_not_run_cleanup () {
  sudo systemctl stop docker
  sudo apt purge docker -y
  rm -fr ~/go
  rm -fr rocksdb
}
