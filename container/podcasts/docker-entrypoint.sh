#!/bin/bash

podcasts_dir="/volumes/podcasts"
config_dir="/volumes/config"

echo started podcast container | ts '%F %T'

echo initialising repository in $podcasts_dir | ts '%F %T'
cd "$podcasts_dir"
git init --quiet
git annex init --quiet
echo re-initialized repository | ts '%F %T'

echo importing podcasts from $config_dir/podcasts - with auth from $config_dir/netrc | ts '%F %T'
echo using template from env variable FEEDTEMPLATE - \"$FEEDTEMPLATE\"
xargs git annex importfeed --template=$FEEDTEMPLATE < $config_dir/podcasts
echo finished importing podcasts | ts '%F %T'

