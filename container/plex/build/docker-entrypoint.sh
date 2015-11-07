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
   -q      if specified the script will change the uid / gid of the service account
   -i      uid to use for couchpotato user (useful is container runs with shared volumes)
   -o      gid to use for the couchpotato user (useful is container runs with shared volumes)
Update of the configuration file
the configuration file will be downloaded from http/https or ftp with the specified credentials.

EOF
}

CMD="plex"
VOL_UID=""
VOL_GID=""
CHANGEID=0
while getopts "hc:qi:o:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         c)
             CMD=$OPTARG
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


if [ "$CMD" = 'plex' ]; then

  # make sure the service user has the correct uid and gid set
  if [ "$CHANGEID" -eq "1" ]; then
    ansible-playbook /opt/plex.yml -c local -t uid --extra-vars "volume_uid=$VOL_UID volume_gid=$VOL_GID"
  fi

  # run plex with the users home directory as data duir
  exec sudo -u plex /bin/bash -c "cd /usr/lib/plexmediaserver ; ./start.sh"
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$CMD"
else
    exec "$cmd" $param
fi
