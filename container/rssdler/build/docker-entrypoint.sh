#!/bin/bash
set -e

cmd=$1
shift
param="$@"

# if the first paramter is rssdler start the
# rssdler script
if [ "$cmd" = 'rssdler' ]; then

    # if the daemon pid exists remove it
    if [ -f /var/lib/rssdler/workingdir/daemon.info ]; then
      rm -f /var/lib/rssdler/workingdir/daemon.info
    fi

    # if the configuration file does not exist copy it
    if [ ! -f /var/lib/rssdler/rssdler.conf ]; then
      cp /opt/rssdler.conf /var/lib/rssdler/rssdler.conf
    fi

    # first paraemter is always rssdler = /usr/bin/rssdler xxx
    exec "/usr/bin/rssdler" $param
fi

# if the first paramter is not rssdler start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$cmd"
else
    exec "$cmd" $param
fi