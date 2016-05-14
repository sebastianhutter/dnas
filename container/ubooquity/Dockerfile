FROM fedora:23

ENV ubooquity_version 1.9.1

# install java
RUN dnf install -y java-1.8.0-openjdk-headless unzip python-pip
# install j2cli
RUN pip install --upgrade j2cli

# download ubooquity
WORKDIR /ubooquity
RUN curl -O http://vaemendis.net/ubooquity/downloads/Ubooquity-${ubooquity_version}.zip && \
    unzip Ubooquity-${ubooquity_version}.zip && rm -f Ubooquity-${ubooquity_version}.zip

# add the entrypoint script
ADD build/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# do some cleanup
# remove unused locales 
WORKDIR /
RUN localedef --list-archive | grep -v -i ^en_US | xargs localedef --delete-from-archive && \
    mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && build-locale-archive && \
    dnf clean -y all

# expose the ubooquity port
EXPOSE 2202
# run the docker entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
