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
   -n      if specified the config file will be updated before the service starts
   -m      if specified the couchpotato source will be updated
   -u      username for the config file download
   -p      password for the config file download
   -f      url to the config file
   -v      Verbose

Update of the configuration file
the configuration file will be downloaded from http/https or ftp with the specified credentials.

EOF
}

CMD="couchpotato"
UPDATE=0
CONFIG=0
USERNAME=""
PASSWORD=""
URL=""
while getopts “hc:nmu:p:f:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         c)
             CMD=$OPTARG
             ;;
         n)
             CONFIG=1
             ;;
         m)
             UPDATE=1
             ;;
         u)
             USERNAME=$OPTARG
             ;;
         p)
             PASSWORD=1
             ;;
         f)
             URL=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done
shift $(expr $OPTIND - 1 )
param="$@"


if [ "$CMD" = 'couchpotato' ]; then

  # run the couchpotato playbook to upgrade the local installation
  if [ "$UPDATE" -eq "1" ]; then
    ansible-playbook /opt/couchpotato.yml -c local -t update
  fi
  # run the couchpotato playbook to copy the newest configuration file from
  # the users git repository
  if [ "$CONFIG" -eq "1" ]; then
    ansible-playbook /opt/couchpotato.yml -c local -t config --extra-vars "configurl=$URL configuser=$USERNAME configpass=$PASSWORD"
  fi

  # if the configuration file does not exist copy it
  # attention: this config file has no api key defined
  if [ ! -f /home/couchpotato/.couchpotato/settings.conf ]; then
    cp /opt/settings.conf /home/couchpotato/.couchpotato/settings.conf
  fi

  exec python /opt/couchpotato/CouchPotato.py $param
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$CMD"
else
    exec "$cmd" $param
fi