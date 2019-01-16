#!/bin/bash

# curl -o-  https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
# wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

#
# We need a shell, ability to download a shell script, and then execute
#
# 1.  All systems will have a shell
# 2.  Systems will have either wget or curl
# 3.  Minimum installs do not have git
#

set -e

if loc=$(which wget 2>/dev/null); then

  cmd="wget -q0- "
  printf "found: wget: $loc [$cmd]\n"

elif loc=$(which curl 2>/dev/null); then

  cmd="curl -o- "
  printf "found: curl: $loc \n"

else 

  
  printf "we need wget or curl for this script to work\n"

fi


