FROM fedora:latest

# basic environment variables for build process
ENV build /tmp/build
ENV ffmpeg_source git://source.ffmpeg.org/ffmpeg.git
ENV yasm_repo git://github.com/yasm/yasm.git
ENV x264_repo git://git.videolan.org/x264.git

# install basic packages
RUN dnf install -y git make gcc cpp kernel-headers glibc-devel glibc-headers python-devel libffi-devel openssl-devel automake autoconf

# get the different source repositories
RUN mkdir ${build}
WORKDIR ${build}

RUN git clone $ffmpeg_source
WORKDIR ${build}/ffmpeg
RUN git clone $yasm_repo
RUN git clone $x264_repo

# compile yasm
WORKDIR ${build}/ffmpeg/yasm
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# compile x264
WORKDIR ${build}/ffmpeg/x264
RUN ./configure --enable-static --enable-shared
RUN make
RUN make install

# now compile ffmpeg
WORKDIR ${build}/ffmpeg
RUN ./configure --disable-asm --enable-libx264 --enable-gpl
RUN make
RUN make install

# enable /usr/local/lib in ld
RUN echo /usr/local/lib > /etc/ld.so.conf.d/local.conf 
RUN ldconfig

# cleanup the build environment
WORKDIR /
RUN rm -rf ${build}
RUN dnf remove -y git make gcc cpp kernel-headers glibc-devel glibc-headers python-devel libffi-devel openssl-devel automake autoconf

# cleanup the container itself
RUN dnf clean all
#RUN rm -rf /usr/bin/*
RUN rm -rf /usr/sbin/*
RUN rm -rf /usr/include/*
RUN rm -rf /usr/share/*
RUN rm -rf /var/log/*

# execute ffmpeg on container execution
ENTRYPOINT ["/usr/local/bin/ffmpeg"]
