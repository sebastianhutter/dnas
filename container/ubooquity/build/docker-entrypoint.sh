#!/bin/bash
set -e

usage()
{
cat << EOF
usage: $0 options

This is the entry point for the docker container.
It takes multiple arguments

OPTIONS:
   -h      Show this message
   -c      the command to run (by default its set to run the dockerized service)
   -n      if specified the config file will be updated before the service starts
   -u      username for the config file download
   -p      password for the config file download
   -f      url to the config file
   -d      url to the config file of httpd

EOF
}

CMD="ubooquity"
CONFIG=0
USERNAME=""
PASSWORD=""
URL=""

<<<<<<< HEAD
while getopts "hc:nmqu:p:f:d:i:o:" OPTION
=======
while getopts "hc:nu:p:f:" OPTION
>>>>>>> origin/master
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
         u)
             USERNAME=$OPTARG
             ;;
         p)
             PASSWORD=$OPTARG
             ;;
         f)
             URL1=$OPTARG
             ;;
         d)
             URL2=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done
shift $(expr $OPTIND - 1 )
param="$@"


if [ "$CMD" = 'ubooquity' ]; then

  if [ "$CONFIG" -eq "1" ]; then
    ansible-playbook /opt/ubooquity.yml -c local -t config --extra-vars "config_url=$URL1 nginx_url=$URL2 config_user=$USERNAME config_pass=$PASSWORD"
  fi

  # create ssl certificate if not existing
  ansible-playbook /opt/ubooquity.yml -c local -t ssl

  #exec sudo -u ubooquity java -jar /opt/ubooquity/Ubooquity.jar -webadmin -headless -workdir /home/ubooquity
  exec sudo /usr/bin/supervisord
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$CMD"
else
    exec "$cmd" $param
fi

