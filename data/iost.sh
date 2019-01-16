#!/bin/bash


  echo "cd $GOPATH/src"
  cd $GOPATH/src
  echo "go get -d github.com/iost-official/go-iost"
  #go get -d github.com/iost-official/go-iost


  echo "cd $GOPATH/src"
  cd $GOPATH/src
  echo "go get -d github.com/iost-official/scaffold"
  go get -d github.com/iost-official/scaffold
  echo "go get -d github.com/iost-official/scaffold"
  go get -d github.com/iost-official/scaffold
  echo "cd  $GOPATH/src/github.com/iost-official/scaffold/"
  cd  $GOPATH/src/github.com/iost-official/scaffold/
  echo "npm install"
  npm install
  echo "npm link"
  npm link
  cd -
  scaf --version
