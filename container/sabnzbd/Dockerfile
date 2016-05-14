FROM sebastianhutter/ffmpeg

# install requirements for sabnzbd and nzbtomedia
RUN dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-23.noarch.rpm \
  http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-23.noarch.rpm 

RUN dnf install -y git gcc redhat-rpm-config python-devel libffi-devel openssl-devel curl \
  python-pip python-yenc unrar unzip tar p7zip p7zip-plugins par2cmdline && \
  pip install --upgrade pip && \
  pip install Cheetah pydbus pyOpenSSL j2cli

# switch the workdir
WORKDIR /

# download sabnzbd and nzbtomedia
run git clone https://github.com/sabnzbd/sabnzbd.git && \
    git clone https://github.com/clinton-hall/nzbToMedia.git

# copy the sabnzbd configuration file
ADD build/sabnzbd.ini.j2 /
# copy the nzbtomedia configuration file
ADD build/autoProcessMedia.cfg.j2 /
# add the entry script
ADD build/docker-entrypoint.sh /

# run the docker entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
