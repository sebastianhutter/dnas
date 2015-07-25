#!/bin/bash
set -e

# if the first paramter is rssdler start the
# rssdler script
if [ "$1" = 'rssdler' ]; then

    # if the configuration file does not exist copy it
    if [ ! -f /var/lib/rssdler/rssdler.conf ]; then
      cp /opt/rssdler.conf /var/lib/rssdler/rssdler.conf
    fi

    # first paraemter is always rssdler = /usr/bin/rssdler xxx
    exec "/usr/bin/$@"
fi

# if the first paramter is not rssdler start
# whatever parameters where given
exec "$@"