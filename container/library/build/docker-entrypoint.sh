#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is plex start the
# plex media service
if [ "$cmd" = 'library' ]; then
  # the nzbtomedia container only serves up the necessary
  # scripts for sabnzbd to execute after a successfull or
  # unsuccessfull download
  /bin/true
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi