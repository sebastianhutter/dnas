#!/bin/bash

podcasts_dir="/volumes/podcasts"
config_dir="/volumes/config"

# variables set by docker
annex_mode="$ANNEXMODE"
template="$FEEDTEMPLATE"
netrc_url="$AUTHURL"
podcasts_url="$PODCASTSURL"


echo started podcast container | ts '%F %T'

echo check annex mode
if [ -z "$annex_mode" ]; then
  echo annex mode is indirect | ts '%F %T'
  annex_mode="indirect"
else
  echo annex mode is direct | ts '%F %T'
  annex_mode="direct"
fi

echo downloading authentication file | ts '%F %T'
if [ -z "$netrc_url" ]; then
  echo no url for download specified - not downloading new auth file | ts '%F %T'
else
  echo authentication file url specified - $netrc_url | ts '%F %T'
  wget -q $netrc_url -O "$config_dir/netrc"
  echo new authentication file downloaded | ts '%F %T'
fi

echo downloading podcasts file | ts '%F %T'
if [ -z "$podcasts_url" ]; then
  echo no url for download specified - not downloading new podcasts file | ts '%F %T'
else
  echo podcasts file url specified - $podcasts_url | ts '%F %T'
  wget -q $podcasts_url -O "$config_dir/podcasts"
  echo new podcasts file downloaded | ts '%F %T'
fi

echo initialising repository in $podcasts_dir | ts '%F %T'
cd "$podcasts_dir"
git init --quiet 
git annex init --quiet
git annex $annex_mode --quiet
echo re-initialized repository | ts '%F %T'

echo importing podcasts from $config_dir/podcasts - with auth from $config_dir/netrc | ts '%F %T'
echo using template from env variable FEEDTEMPLATE - \"$template\"
xargs git annex importfeed --template=$template < $config_dir/podcasts
echo finished importing podcasts | ts '%F %T'