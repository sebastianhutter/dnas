#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is plex start the
# plex media service
if [ "$cmd" = 'sabnzbd' ]; then

  # if the configuration file does not exist copy it
  # attention: this config file should not have the api_key parameter defined!
  if [ ! -f /home/sabnzbd/.sabnzbd/sabnzbd.ini ]; then
    cp /opt/sabnzbd.ini /home/sabnzbd/.sabnzbd/sabnzbd.ini
  fi


  exec python /opt/sabnzbd/SABnzbd.py $param
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi