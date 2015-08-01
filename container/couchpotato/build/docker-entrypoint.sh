#!/bin/bash
set -e

cmd=$1
shift
param="$@"


if [ "$cmd" = 'couchpotato' ]; then

  # if the configuration file does not exist copy it
  # attention: this config file should not have the api_key defined!
  if [ ! -f /home/couchpotato/.couchpotato/settings.conf ]; then
      cp /opt/settings.conf /home/couchpotato/.couchpotato/settings.conf
    fi

  exec python /opt/couchpotato/CouchPotato.py $param
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi