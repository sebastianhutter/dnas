#!/bin/bash

# this script starts or stops all the docker container necessary for dnas
# in the correct order

# if we are running as root start with the setup process
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

cmd=$1
shift
param="$@"

if [ "$cmd" = 'start' ]; then
  /usr/bin/systemctl start library
  /usr/bin/systemctl start nzbtomedia
  /usr/bin/systemctl start rssdler-data
  /usr/bin/systemctl start rssdler
  /usr/bin/systemctl start sabnzbd-data
  /usr/bin/systemctl start sabnzbd
  /usr/bin/systemctl start plex-data
  /usr/bin/systemctl start plex
  /usr/bin/systemctl start sickbeard-data
  /usr/bin/systemctl start sickbeard
  /usr/bin/systemctl start couchpotato-data
  /usr/bin/systemctl start couchpotato
  exit 0
fi


if [ "$cmd" = 'stop' ]; then
  /usr/bin/docker stop couchpotato
  /usr/bin/docker stop couchpotato-data
  /usr/bin/docker stop sickbeard
  /usr/bin/docker stop sickbeard-data
  /usr/bin/docker stop plex
  /usr/bin/docker stop plex-data
  /usr/bin/docker stop sabnzbd
  /usr/bin/docker stop sabnzbd-data
  /usr/bin/docker stop rssdler
  /usr/bin/docker stop rssdler-data
  /usr/bin/docker stop nzbtomedia
  /usr/bin/docker stop library
  exit 0
fi

echo please use 'start' or 'stop' to start or stop the docker containers
exit 1