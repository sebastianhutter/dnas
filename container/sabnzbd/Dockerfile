FROM sebastianhutter/ffmpeg

# set workdir
WORKDIR /

# install requirements for sabnzbd and nzbtomedia
RUN dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-23.noarch.rpm \
  http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-23.noarch.rpm 

RUN dnf install -y git gcc redhat-rpm-config python-devel libffi-devel openssl-devel curl \
  python-pip python-yenc unrar unzip tar p7zip p7zip-plugins par2cmdline && \
  pip install --upgrade pip && \
  pip install --upgrade Cheetah pydbus pyOpenSSL j2cli


# download sabnzbd and nzbtomedia
RUN git clone https://github.com/sabnzbd/sabnzbd.git && \
    git clone https://github.com/clinton-hall/nzbToMedia.git

# copy the sabnzbd configuration file
ADD build/sabnzbd.ini /sabnzbd/sabnzbd.ini
# copy the nzbtomedia configuration file
ADD build/autoProcessMedia.cfg /nzbToMedia/autoProcessMedia.cfg
# add the entry script
ADD build/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# run the docker entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
