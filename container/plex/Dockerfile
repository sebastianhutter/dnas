FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook plex.yml -c local
WORKDIR /
RUN rm -rf /tmp/build

EXPOSE 32400
EXPOSE 1900/UDP
EXPOSE 3005
EXPOSE 5353/UDP
EXPOSE 8324
EXPOSE 32410/UDP
EXPOSE 32412/UDP
EXPOSE 32413/UDP
EXPOSE 32414/UDP
EXPOSE 32469


# become rssdler user
USER plex
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
# if no parameters are given show the help
#CMD ["ec", "--help"]