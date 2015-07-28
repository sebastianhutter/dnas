FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook sabnzbd.yml -c local
WORKDIR /
RUN rm -rf /tmp/build

EXPOSE 8085

# become rssdler user
USER sabnzbd
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["sabnzbd" ,"-s", "0.0.0.0:8085"]

