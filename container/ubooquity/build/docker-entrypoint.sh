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


EOF
}

CMD="ubooquity"
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
         ?)
             usage
             exit
             ;;
     esac
done
shift $(expr $OPTIND - 1 )
param="$@"


if [ "$CMD" = 'ubooquity' ]; then

  # run supervisor to start
  # the necessary services
  exec sudo -u ubooquity java -jar /opt/ubooquity/Ubooquity.jar -webadmin -headless -workdir /home/ubooquity
fi

# if the first paramter is not plex start
# whatever parameters where given
if [ -z "$param" ]; then
    exec "$CMD"
else
    exec "$cmd" $param
fi

