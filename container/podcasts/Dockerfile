FROM sebastianhutter/git-annex:latest

# add moreutils, necessary for the entry point script
RUN dnf install -y moreutils

# create non-root account which runs everything
RUN adduser podcast

# create volume directories
RUN mkdir -p /volumes/podcasts; mkdir -p /volumes/config
# create empty podcasts file and netrc file
RUN echo "machine www.domain.com login username password userstopsecretpass" > /volumes/config/netrc
RUN echo "http://www.domain.com/rss.xml" > /volumes/config/podcasts
RUN chown -R podcast:podcast /volumes/*

# create softlink for netrc
RUN ln -s /volumes/config/netrc /home/podcast/.netrc

# publish volumes for podcasts and configuration
VOLUME /volumes/podcasts
VOLUME /volumes/config

# copy entrypoint script
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
RUN chmod +x /opt/docker-entrypoint.sh

# set user
USER podcast

# set the default env variable for the git-annex template
# and download locations for the auth url and podcasts url
ENV FEEDTEMPLATE='${feedtitle}/${itempubdate}-${itemtitle}${extension}'
ENV AUTHURL=""
ENV PODCASTSURL=""

# set the entrypoint
ENTRYPOINT ["/opt/docker-entrypoint.sh"]