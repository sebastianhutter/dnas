#!/bin/bash
set -e

echo running entrypoint script
echo who am im
id

echo parameters
echo $@

# if the first paramter is rssdler start the
# rssdler script
if [ "$1" = 'rssdler' ]; then
    # shift the parametes by one
    shift

    echo received rssdler as parameters
    echo remaining parameters

    echo $@

    # if the configuration file does not exist copy it
    if [ ! -f /var/lib/rssdler/rssdler.conf ]; then
      cp /opt/rssdler.conf /var/lib/rssdler/rssdler.conf
    fi

    # first paraemter is always rssdler = /usr/bin/rssdler xxx
    exec "/usr/bin/rssdler" "$@"
fi

# if the first paramter is not rssdler start
# whatever parameters where given
exec "$@"