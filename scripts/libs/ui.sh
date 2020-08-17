#!/bin/bash

export NO_COLOR='\033[0m'
export OK_COLOR='\033[32;01m'
export RUN_COLOR='\033[32;01m'
export ERROR_COLOR='\033[31;01m'
export WARN_COLOR='\033[33;01m'
export MSG_COLOR='\033[33;01m'
export CMD_COLOR='\033[33;01m'

#
# foreground
#

# default
d="\e[39m"

# light green
lg="\e[92m"

# dark green
dg="\e[32m"

# dark yellow
dy="\e[33m"

# light yellow
ly="\e[93m"

# dark red
dr="\e[31m"

# light red
lr="\e[91m"

# white
w="\e[97m"

# rest all
zz="\e[0m"


#
# background
#

# background reset
bd="\e[49m"

# background red
br="\e[41m"

# background white
bw="\e[107m"



ui_log() {
  LOG_PREFIX="${DISTRIBUTION}-${RELEASE}"
  echo "    [${LOG_PREFIX}] ${1}"
}

ui_warn() {
  LOG_PREFIX="${DISTRIBUTION}-${RELEASE}"
  echo -e "${WARN_COLOR}==> [${LOG_PREFIX}] ${1}${NO_COLOR}"
}

ui_info() {
  LOG_PREFIX="${DISTRIBUTION}-${RELEASE}"
  echo -e "${OK_COLOR}==> [${LOG_PREFIX}] ${1}${NO_COLOR}"
}

ui_confirm() {
  LOG_PREFIX="${DISTRIBUTION}-${RELEASE}"
  question=${1}
  default=${2}
  default_prompt=

  if [ $default = 'n' ]; then
    default_prompt="y/N"
    default='No'
  else
    default_prompt="Y/n"
    default='Yes'
  fi

  echo -e -n "${WARN_COLOR}==> [${LOG_PREFIX}] ${question} [${default_prompt}] ${NO_COLOR}" >&2
  read answer

  if [ -z $answer ]; then
    debug "Answer not provided, assuming '${default}'"
    answer=${default}
  fi

  if $(echo ${answer} | grep -q -i '^y'); then
    return 0
  else
    return 1
  fi
}

ui_debug() {
  LOG_PREFIX="${DISTRIBUTION}-${RELEASE}"
  [ ! $DEBUG ] || echo "    [${LOG_PREFIX}] [DEBUG] ${1}" >&2
}
