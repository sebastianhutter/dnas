FROM fedora:23

# set workdir
WORKDIR /

# install couchpotato requirements
RUN dnf install -y git gcc redhat-rpm-config python-devel libffi-devel \
  openssl-devel curl python-pip libxml2-devel libxslt-devel && \
  pip install --upgrade pip && \
  pip install --upgrade pyOpenSSL j2cli lxml

# download couchpotato
RUN git clone https://github.com/CouchPotato/CouchPotatoServer.git

# copy the couchpotato configuration file
ADD build/settings.conf /CouchPotatoServer/settings.conf
# add the entry script
ADD build/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# run the docker entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
