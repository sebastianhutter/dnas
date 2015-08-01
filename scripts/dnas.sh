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
rssdler
rssdler-discovery
sabnzbd-data
sabnzbd
sabnzbd-discovery
nzbtomedia-discovery
plex-data
plex-discovery
plex
sickbeard-data
sickbeard
sickbeard-discovery
couchpotato-data
couchpotato
couchpotato-discovery
)



cmd=$1
shift
param="$@"


if [ "$cmd" = 'start' ]; then
  for (( id=0 ; id<=${#services[@]}-1 ; id++ ))
  do
    echo starting service ${services[id]}
    /usr/bin/systemctl start ${services[id]}
    sleep 5
  done
  exit 0
fi


if [ "$cmd" = 'stop' ]; then
  for (( id=${#services[@]}-1 ; id>=0 ; id-- ))
  do
    echo stopping service ${services[id]}
    /usr/bin/systemctl stop ${services[id]}\
    sleep 5
  done
  exit 0
fi

echo please use 'start' or 'stop' to start or stop the docker containers
exit 1