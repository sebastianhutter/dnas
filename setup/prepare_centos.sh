#!/bin/bash

# this script prepares the centos machine to run the docker nas setup
# script


# if we are running as root start with the setup process
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

echo "install the epel repositories"
yum install -y epel-release > /dev/null

echo "install git"
yum install -y git > /dev/null

echo "install ansible"
yum install -y ansible > /dev/null

