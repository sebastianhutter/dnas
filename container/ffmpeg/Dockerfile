FROM fedora:latest

# basic environment variables for build process
ENV build /tmp/build

# see https://trac.ffmpeg.org/wiki/CompilationGuide/Centos 
# for detailed instructions on how to build ffmpeg

# install basic packages
RUN dnf install -y git tar gzip make gcc gcc-c++ kernel-headers glibc-devel glibc-headers python-devel yasm nasm \
  libffi-devel openssl-devel automake autoconf zlib-devel cmake freetype-devel libtool mercurial nasm pkgconfig

# get the different source repositories
WORKDIR ${build}

# # compile yasm
# RUN git clone --depth 1 git://github.com/yasm/yasm.git && \
#   cd yasm && \ 
#   autoreconf -fiv && \
#   ./configure --prefix="${build}" && \
#   make && \
#   make install && \
#   make distclean

# compile libx264
RUN git clone --depth 1 git://git.videolan.org/x264 && \
cd x264 && \
PKG_CONFIG_PATH="${build}/lib/pkgconfig" ./configure --prefix="${build}" --enable-static && \
#./configure --enable-static && \
make && \
make install && \
make distclean

# libx265
RUN hg clone https://bitbucket.org/multicoreware/x265 && \
cd x265/build/linux && \
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${build}" -DENABLE_SHARED:bool=off ../../source && \
#cmake -G "Unix Makefiles" -DENABLE_SHARED:bool=off ../../source && \
make && \
make install 

# libfdk_aac
RUN git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure --prefix="${build}" --disable-shared && \
#./configure --disable-shared && \
make && \
make install && \
make distclean

# libmp3lame
RUN curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
tar xzvf lame-3.99.5.tar.gz && \
cd lame-3.99.5 && \
./configure --prefix="${build}" --disable-shared --enable-nasm && \
#./configure --disable-shared --enable-nasm && \
make && \
make install && \
make distclean

# libopus 
RUN git clone https://git.xiph.org/opus.git && \
cd opus && \
autoreconf -fiv && \
./configure --prefix="${build}" --disable-shared && \
#./configure --disable-shared && \
make && \
make install && \
make distclean

# libogg
RUN curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz && \
tar xzvf libogg-1.3.2.tar.gz && \
cd libogg-1.3.2 && \
./configure --prefix="${build}" --disable-shared && \
#./configure --disable-shared && \
make && \
make install && \
make distclean

# libvorbis
RUN curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz && \
tar xzvf libvorbis-1.3.4.tar.gz && \
cd libvorbis-1.3.4 && \ 
LDFLAGS="-L${build}/lib" CPPFLAGS="-I${build}/include" ./configure --prefix="${build}" --with-ogg="${build}" --disable-shared && \
#./configure --disable-shared && \
make && \
make install && \
make distclean

# libvpx
#RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
#cd libvpx && \
#./configure --prefix="${build}" --disable-examples && \
#make && \
#make install && \
#make clean

# ffmpeg itself!!!
RUN git clone http://source.ffmpeg.org/git/ffmpeg.git && \
cd ffmpeg && \
PKG_CONFIG_PATH="${build}/lib/pkgconfig" ./configure --prefix="${build}" --extra-cflags="-I${build}/include" \
  --extra-ldflags="-L${build}/lib" --pkg-config-flags="--static" --enable-gpl --enable-nonfree \
  --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libvorbis \
  --enable-libx264 --enable-libx265 && \
make && \
make install && \
make distclean && \
hash -r

# copy installation files
RUN cp -a ${build}/bin/* /usr/local/bin && \
    cp -a ${build}/include/* /usr/local/include && \
    cp -a ${build}/lib/* /usr/local/lib && \
    cp -a ${build}/share/* /usr/local/share

# cleanup the build environment
WORKDIR /
RUN rm -rf ${build}

# execute ffmpeg on container execution
ENTRYPOINT ["/usr/local/bin/ffmpeg"]
