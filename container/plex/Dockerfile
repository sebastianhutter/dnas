FROM ansible/centos7-ansible:stable


# create data directories
RUN  adduser plex && \ 
     mkdir -p /var/lib/plex/{download,workingdir,logs} && \
     chown -R plex:plex /var/lib/plex