#!/bin/bash

#
#  support for a wider number Ubuntu releases (16.04, 16.10, 18.04, and 18.10)
#  18.10 has k8s, docker, lxc,
#
# Array of supported versions
declare -a UBUNTU_MANDATORY=('xenial' 'yakkety', 'bbionic');
# check the version and extract codename of ubuntu if release codename not provided by user
if [ -z "$1" ]; then
    source /etc/lsb-release || \
        (echo "---> msg: ERROR: Release information not found, Ubuntu version unknown"; exit 76)
    CODENAME=${DISTRIB_CODENAME}
else
    CODENAME=${1}
fi

# check version is supported
if echo ${UBUNTU_MANDATORY[@]} | grep -q -w ${CODENAME}; then
    echo "---> msg: Installing Ubuntu ${CODENAME}"
else
    echo "---> msg: ERROR: Ubuntu ${CODENAME} is not supported"
    exit 77
fi

exit;
