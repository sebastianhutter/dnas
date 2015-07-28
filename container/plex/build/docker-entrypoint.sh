#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is plex start the
# plex media service
if [ "$cmd" = 'plex' ]; then
  # the plexmedia server can be started by simply running the start script
  # in the plexmedia server lib directory
  cd /usr/lib/plexmediaserver
  exec ./start.sh
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi