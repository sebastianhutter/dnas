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
   -q      if specified the script will change the uid / gid of the service account
   -i      uid to use for couchpotato user (useful is container runs with shared volumes)
   -o      gid to use for the couchpotato user (useful is container runs with shared volumes)
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
CHANGEID=0
VOL_UID=""
VOL_GID=""
while getopts "hc:nmqu:p:f:i:o:" OPTION
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
         i)
             VOL_UID=$OPTARG
             ;;
         o)
             VOL_GID=$OPTARG
             ;;
         q)
             CHANGEID=1
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
    ansible-playbook /opt/couchpotato.yml -c local -t config --extra-vars "config_url=$URL config_user=$USERNAME config_pass=$PASSWORD"
  fi

  # before we can start couchpotato we need to make sure a configuration
  # file does exists. if the file does not exist the default file will be copied
  ansible-playbook /opt/couchpotato.yml -c local -t default_config

  # now last step is to make sure the user in thelsd docker container
  # has the correct uid and gid set to properly work with shared volumes
  if [ "$CHANGEID" -eq "1" ]; then
    ansible-playbook /opt/couchpotato.yml -c local -t uid --extra-vars "volume_uid=$VOL_UID volume_gid=$VOL_GID"
  fi

  # run couchpotato with the users home directory as data duir
  exec sudo -u couchpotato python /opt/couchpotato/CouchPotato.py --data_dir /home/couchpotato $param
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$CMD"
else
    exec "$cmd" $param
fi