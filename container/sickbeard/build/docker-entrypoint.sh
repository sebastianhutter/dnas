#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is plex start the
# plex media service
if [ "$cmd" = 'sickbeard' ]; then

  # if the configuration file does not exist copy it
  if [ ! -f /opt/sickbeard-data/config.ini ]; then
    cp /opt/config.ini /opt/sickbeard-data/config.ini
  fi

  exec python /opt/sickbeard/SickBeard.py $param
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi