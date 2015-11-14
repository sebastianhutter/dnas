#!/bin/bash
set -e

usage()
{
cat << EOF
usage: $0 options

This is the entry point for the docker container.
It takes multiple argumens=ts

OPTIONS:
   -h      Show this message
   -c      the command to run (by default its set to run the dockerized service)

EOF
}

CMD="openvpnas"

while getopts "hc:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         c)
             CMD=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done
shift $(expr $OPTIND - 1 )
param="$@"


if [ "$CMD" = 'openvpnas' ]; then

  # remove pid file if it exists
  if [ -e "/var/run/openvpnas.pid" ]; then
    sudo rm -f "/var/run/openvpnas.pid" &>/dev/null
  fi

  # run the openvpn service
  # for openvpn to work properly we need iptables
  # add --cap-add=NET_ADMIN --cap-add=NET_RAW --device=/dev/net/tun to your docker command line to make it work
  exec sudo -u root /usr/local/openvpn_as/scripts/openvpnas --logfile=- --pidfile=/var/run/openvpnas.pid --nodaemon
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$CMD"
else
    exec "$cmd" $param
fi
