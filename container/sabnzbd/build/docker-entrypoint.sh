#!/bin/bash

# the local configuration file to be replaced / parsed
SABNZBD_CONFIG_LOCAL="/sabnzbd/sabnzbd.ini"
NZBTOMEDIA_CONFIG_LOCAL="/nzbToMedia/autoProcessMedia.cfg"

# sabnzbd: check for configuration download
if [ -z "$SABNZBD_CONFIG_LOCAL" ]; then 
  echo "sabnzbd: No config url set. Will use local configuration file"
else
  echo "sabnzbd: Config url is set. Download the configuration file"
  # now try to download the configuration file
  if [ -z "$SABNZBD_CONFIG_USERNAME" ] || [ -z "$SABNZBD_CONFIG_PASSWORD" ]; then
    # if no usename and password is specified
    curl "$SABNZBD_CONFIG_URL" -o "$SABNZBD_CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  else
    curl --user $SABNZBD_CONFIG_USERNAME:$SABNZBD_CONFIG_PASSWORD "$SABNZBD_CONFIG_URL" -o "$SABNZBD_CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  fi
fi

# first check if the download url is set. if so try to download the file via curl
if [ -z "$NZBTOMEDIA_CONFIG_LOCAL" ]; then 
  echo "nzbtomedia: No config url set. Will use local configuration file"
else
  echo "nzbtomedia: Config url is set. Download the configuration file"
  # now try to download the configuration file
  if [ -z "$NZBTOMEDIA_CONFIG_USERNAME" ] || [ -z "$NZBTOMEDIA_CONFIG_PASSWORD" ]; then
    # if no usename and password is specified
    curl "$NZBTOMEDIA_CONFIG_URL" -o "$NZBTOMEDIA_CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  else
    curl --user $NZBTOMEDIA_CONFIG_USERNAME:$NZBTOMEDIA_CONFIG_PASSWORD "$NZBTOMEDIA_CONFIG_URL" -o "$NZBTOMEDIA_CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  fi
fi

# now parse the configuration files
echo "sabnzbd: Parse the configuration file with j2"
mv "$SABNZBD_CONFIG_LOCAL" "$SABNZBD_CONFIG_LOCAL.orig"
j2 "$SABNZBD_CONFIG_LOCAL.orig" > "$SABNZBD_CONFIG_LOCAL"
[ $? -ne 0 ] && exit 1

echo "nzbtomedia: Parse the configuration file with j2"
mv "$NZBTOMEDIA_CONFIG_LOCAL" "$NZBTOMEDIA_CONFIG_LOCAL.orig"
j2 "$NZBTOMEDIA_CONFIG_LOCAL.orig" > "$NZBTOMEDIA_CONFIG_LOCAL"
[ $? -ne 0 ] && exit 1

# run sabnzbd
echo "Run ubooquity"
java -jar /ubooquity/Ubooquity.jar -webadmin -headless -workdir /ubooquity