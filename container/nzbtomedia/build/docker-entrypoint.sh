#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is plex start the
# plex media service
if [ "$cmd" = 'nzbtomedia' ]; then
  # the nzbtomedia container only serves up the necessary
  # scripts for sabnzbd to execute after a successfull or
  # unsuccessfull download

  # if the configuration file does not exist copy it
  if [ ! -f /opt/nzbtomedia/autoProcessMedia.cfg.spec ]; then
    cp /opt/nzbtomedia/autoProcessMedia.cfg.spec /opt/nzbtomedia/autoProcessMedia.cfg
  fi

  exec /bin/true
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi