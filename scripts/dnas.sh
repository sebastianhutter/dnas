#!/bin/bash

# this script starts or stops all the docker container necessary for dnas
# in the correct order

# if we are running as root start with the setup process
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# services to start or stop
services=(
library
nzbtomedia
rssdler-data
rssdler-discovery
rssdler
sabnzbd-data
sabnzbd-discovery
sabnzbd
plex-data
plex-discovery
plex
sickbeard-data
sickbeard-discovery
sickbeard
couchpotato-data
couchpotato-discovery
couchpotato
)



cmd=$1
shift
param="$@"


if [ "$cmd" = 'start' ]; then
  for (( id=0 ; id<=${#services[@]}-1 ; id++ ))
  do
    echo starting service ${services[id]}
    /usr/bin/systemctl start ${services[id]}
  done
  exit 0
fi


if [ "$cmd" = 'stop' ]; then
  for (( id=${#services[@]}-1 ; id>=0 ; id-- ))
  do
    echo stopping service ${services[id]}
    /usr/bin/systemctl stop ${services[id]}
  done
  exit 0
fi

echo please use 'start' or 'stop' to start or stop the docker containers
exit 1