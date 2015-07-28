#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is plex start the
# plex media service
if [ "$cmd" = 'sabnzbd' ]; then
  # the plexmedia server can be started by simply running the start script
  # in the plexmedia server lib directory
  cd
  exec python /opt/sabnzbd/SABnzbd.py $param
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi