FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook nzbtomedia.yml -c local
WORKDIR /
RUN rm -rf /tmp/build

VOLUME /opt/nzbtomedia

# become rssdler user
USER nzbtomedia
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["nzbtomedia"]

