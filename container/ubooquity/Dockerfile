FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook ubooquity.yml -c local -t setup
WORKDIR /
RUN rm -rf /tmp/build

# used for ubooquity website
EXPOSE 2022

# create a volume for the persistent data of the ubooquity server
VOLUME /home/ubooquity

# become rssdler user
USER container
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["-c ubooquity"]

