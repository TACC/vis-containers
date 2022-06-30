# Pull base image
FROM centos:centos7 AS builder

LABEL Name=displaycluster Version=0.0.1

RUN echo "Install Dependencies and prerequisites" && \
yum -y update && \
yum -y install epel-release && \
yum -y group install "Development Tools" && \
yum -y install git cmake wget zlib-devel bzip2-devel python2-devel vim libX11-devel libXext-devel libXtst-devel mesa-libGL-devel mesa-libGLU-devel

ARG INSTPATH=/opt/apps

ENV PATH="$PATH:${INSTPATH}/bin" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${INSTPATH}/lib" \
    INCLUDE="$INCLUDE:${INSTPATH}/include" \
    ncores=4 \
    CFLAGS=-fPIC \
    CC=gcc

RUN mkdir DC

##########################################################
######################## OpenMPI #########################
##########################################################

WORKDIR /DC

RUN mkdir ompi

WORKDIR /DC/ompi

ARG ompi_major=1 \ 
    ompi_minor=4 \
    ompi_micro=1

ARG ompi_versn=${ompi_major}.${ompi_minor}.${ompi_micro}
 
RUN wget https://download.open-mpi.org/release/open-mpi/v${ompi_major}.${ompi_minor}/openmpi-${ompi_versn}.tar.gz && \
tar xzvf openmpi-${ompi_versn}.tar.gz

WORKDIR /DC/ompi/openmpi-${ompi_versn}

RUN ./configure --enable-mpi-threads --prefix="${INSTPATH}" && \
make -j && \
make install -j

##########################################################
######################### Boost ##########################
##########################################################

ARG boost_major=1 \
    boost_minor=51 \
    boost_micro=0

ARG boost_versn=${boost_major}.${boost_minor}.${boost_micro}

WORKDIR /DC

RUN mkdir boost

WORKDIR /DC/boost

RUN wget https://sourceforge.net/projects/boost/files/boost/${boost_versn}/boost_${boost_major}_${boost_minor}_${boost_micro}.tar.gz && \
tar xzvf boost_${boost_major}_${boost_minor}_${boost_micro}.tar.gz

WORKDIR /DC/boost/boost_${boost_major}_${boost_minor}_${boost_micro}

RUN ./bootstrap.sh --with-python=/usr/bin/python --with-python-version=2.7.5 --with-python-root=/usr --prefix="${INSTPATH}" --with-toolset=gcc --with-libraries=all && \
    ./b2 -j ${ncores} include="/usr/include/python2.7" --toolset=gcc --prefix="${INSTPATH}" install


##########################################################
######################### NASM ###########################
##########################################################

ARG nasm_major=2 \
    nasm_minor=14 \
    nasm_micro=02

ARG nasm_versn=${nasm_major}.${nasm_minor}.${nasm_micro}

WORKDIR /DC

RUN mkdir nasm

WORKDIR /DC/nasm

RUN wget https://www.nasm.us/pub/nasm/releasebuilds/${nasm_versn}/nasm-${nasm_versn}.tar.gz && \
tar xvfz nasm-${nasm_versn}.tar.gz

WORKDIR /DC/nasm/nasm-${nasm_versn}

RUN ./configure --prefix="${INSTPATH}" && \
make -j && \
make install -j

##########################################################
######################### YASM ###########################
##########################################################

ARG yasm_major=1 \
    yasm_minor=3 \
    yasm_micro=0

ARG yasm_versn=${yasm_major}.${yasm_minor}.${yasm_micro}

WORKDIR /DC

RUN mkdir yasm

WORKDIR /DC/yasm

RUN wget http://www.tortall.net/projects/yasm/releases/yasm-${yasm_versn}.tar.gz && \
tar xvfz yasm-${yasm_versn}.tar.gz

WORKDIR /DC/yasm/yasm-${yasm_versn}


RUN ./configure --prefix="${INSTPATH}" && \
make -j && \
make install -j


##################################################################
######################### libjpegturbo ###########################
##################################################################

ARG ljpt_major=1 \
    ljpt_minor=1 \
    ljpt_micro=90

ARG ljpt_versn=${ljpt_major}.${ljpt_minor}.${ljpt_micro}

WORKDIR /DC

RUN mkdir ljpt

WORKDIR /DC/ljpt

RUN wget "https://sourceforge.net/projects/libjpeg-turbo/files/${ljpt_versn}%20%281.2beta1%29/libjpeg-turbo-${ljpt_versn}.tar.gz" && \
tar xzvf libjpeg-turbo-${ljpt_versn}.tar.gz

WORKDIR /DC/ljpt/libjpeg-turbo-${ljpt_versn}

RUN ./configure --prefix="$INSTPATH" && \
make -j && \
make install -j

############################################################
######################### ffmpeg ###########################
############################################################

ARG lame_major=3  \
    lame_minor=99 \
    lame_micro=5 

ARG lame_versn=${lame_major}.${lame_minor}.${lame_micro} \
    opus_major=1  \
    opus_minor=0  \
    opus_micro=2

ARG opus_versn=${opus_major}.${opus_minor}.${opus_micro} \ 
    ogg_major=1  \
    ogg_minor=1  \
    ogg_micro=4

ARG ogg_versn=${ogg_major}.${ogg_minor}.${ogg_micro} \
    theora_major=1 \
    theora_minor=1 \
    theora_micro=1

ARG theora_versn=${theora_major}.${theora_minor}.${theora_micro} \
    vorbis_major=1 \
    vorbis_minor=3 \
    vorbis_micro=3

ARG vorbis_versn=${vorbis_major}.${vorbis_minor}.${vorbis_micro} \ 
    vpx_major=1 \
    vpx_minor=2 \
    vpx_micro=0

ARG vpx_versn=${vpx_major}.${vpx_minor}.${vpx_micro} \
    ffmpeg_major=0 \
    ffmpeg_minor=9 \
    ffmpeg_micro=1

ARG ffmpeg_versn=${ffmpeg_major}.${ffmpeg_minor}.${ffmpeg_micro}

WORKDIR /DC

RUN mkdir ffmpeg

WORKDIR /DC/ffmpeg

RUN wget https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20170101-2245-stable.tar.bz2 && \
tar xvfj x264-snapshot-20170101-2245-stable.tar.bz2

WORKDIR /DC/ffmpeg/x264-snapshot-20170101-2245-stable

RUN ./configure --prefix="$INSTPATH" --enable-shared && \
make -j ${ncores} && \
make install -j ${ncores}

WORKDIR /DC/ffmpeg

RUN curl -O -L https://downloads.sourceforge.net/project/lame/lame/${lame_major}.${lame_minor}/lame-${lame_versn}.tar.gz && \
tar xzvf lame-${lame_versn}.tar.gz

WORKDIR /DC/ffmpeg/lame-${lame_versn} 

RUN ./configure --prefix="$INSTPATH" --disable-static --enable-nasm && \
make -j ${ncores} && \
make install -j ${ncores}

WORKDIR /DC/ffmpeg

RUN wget http://downloads.xiph.org/releases/ogg/libogg-${ogg_versn}.tar.gz && \
tar xzvf libogg-${ogg_versn}.tar.gz

WORKDIR /DC/ffmpeg/libogg-${ogg_versn}

RUN ./configure --prefix="$INSTPATH" --disable-static && \
make -j ${ncores} && \
make install -j ${ncores}

WORKDIR /DC/ffmpeg

RUN wget http://downloads.xiph.org/releases/theora/libtheora-${theora_versn}.tar.gz && \
tar xzvf libtheora-${theora_versn}.tar.gz

WORKDIR /DC/ffmpeg/libtheora-${theora_versn}

RUN ./configure --prefix="$INSTPATH" --disable-static --with-ogg="$INSTPATH"
RUN make -j ${ncores}
RUN make install -j ${ncores}

WORKDIR /DC/ffmpeg

RUN wget http://downloads.xiph.org/releases/vorbis/libvorbis-${vorbis_versn}.tar.gz && \
tar xzvf libvorbis-${vorbis_versn}.tar.gz

WORKDIR /DC/ffmpeg/libvorbis-${vorbis_versn}

RUN ./configure --prefix="$INSTPATH" --with-ogg="$INSTPATH" --disable-static
RUN make -j ${ncores}
RUN make install -j ${ncores}

WORKDIR /DC/ffmpeg

RUN wget https://chromium.googlesource.com/webm/libvpx/+archive/v${vpx_versn}.tar.gz
RUN mkdir vpx-${vpx_versn}
RUN tar xzvf v${vpx_versn}.tar.gz -C vpx-${vpx_versn}

WORKDIR /DC/ffmpeg/vpx-${vpx_versn}

RUN ./configure --prefix="$INSTPATH" --disable-examples --disable-unit-tests --enable-shared --disable-static --as=yasm
RUN make -j ${ncores}
RUN make install -j ${ncores}

WORKDIR /DC/ffmpeg

RUN curl -O -L http://www.ffmpeg.org/releases/ffmpeg-${ffmpeg_versn}.tar.gz
RUN tar xzvf ffmpeg-${ffmpeg_versn}.tar.gz

WORKDIR /DC/ffmpeg/ffmpeg-${ffmpeg_versn}

RUN ./configure --prefix="$INSTPATH" \
  --extra-cflags="-I$INSTPATH/include" \
  --extra-ldflags="-L$INSTPATH/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$INSTPATH/bin" \
  --enable-gpl \
  --disable-static \
  --enable-shared \
  --enable-libmp3lame \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-nonfree

RUN make -j ${ncores} && \
    make install -j ${ncores} && \
    hash -d $INSTPATH/ffmpeg

############################################################
########################## QT4 #############################
############################################################

ARG qt4_major=4 \
    qt4_minor=8 \
    qt4_micro=2

ARG qt4_versn=${qt4_major}.${qt4_minor}.${qt4_micro}

WORKDIR /DC

RUN mkdir qt4

WORKDIR /DC/qt4

RUN wget https://download.qt.io/archive/qt/${qt4_major}.${qt4_minor}/${qt4_versn}/qt-everywhere-opensource-src-${qt4_versn}.tar.gz
RUN tar xzvf qt-everywhere-opensource-src-${qt4_versn}.tar.gz

WORKDIR /DC/qt4/qt-everywhere-opensource-src-${qt4_versn}

RUN ./configure -opensource -confirm-license --prefix=$INSTPATH -release -nomake examples -nomake tests && \
    make -j ${ncores} && \
    make install -j ${ncores}


##########################################################
##################### DisplayCluster #####################
##########################################################

WORKDIR /DC

RUN mkdir displaycluster

WORKDIR /DC/displaycluster

RUN git clone https://github.com/andrewsolis/DisplayCluster.git
WORKDIR /DC/displaycluster/DisplayCluster

RUN mkdir Build

WORKDIR /DC/displaycluster/DisplayCluster/build

RUN cmake -DBUILD_DISPLAYCLUSTER=ON -DQT_MOC_EXECUTABLE=$INSTPATH/bin/moc -DQT_RCC_EXECUTABLE=$INSTPATH/bin/rcc  \ 
          -DQT_UIC_EXECUTABLE=$INSTPATH/bin/uic -DLibJpegTurbo_LIBRARY=$INSTPATH/lib/libturbojpeg.so \ 
          -DFFMPEG_avcodec_LIBRARY=$INSTPATH/lib/libavcodec.so -DFFMPEG_avformat_LIBRARY=$INSTPATH/lib/libavformat.so \ 
          -DFFMPEG_avutil_LIBRARY=$INSTPATH/lib/libavutil.so -DFFMPEG_swscale_LIBRARY=$INSTPATH/lib/libswscale.so \ 
          -DFFMPEG_theora_LIBRARY=$INSTPATH/lib/libtheora.so -DFFMPEG_vorbis_LIBRARY=$INSTPATH/lib/libvorbis.so \ 
          -DFFMPEG_vorbisenc_LIBRARY=$INSTPATH/lib/libvorbisenc.so -DCMAKE_INSTALL_PREFIX=$INSTPATH ../


RUN make -j ${ncores} && \
    make install -j ${ncores}

RUN cp /DC/displaycluster/DisplayCluster/examples/configuration.xml $INSTPATH

FROM centos:centos7

RUN echo "Install Dependencies and prerequisites on build image" && \
yum -y update && \
yum -y install epel-release && \
yum -y group install "Development Tools" && \
yum -y install git cmake wget zlib-devel bzip2-devel python2-devel vim libX11-devel libXext-devel libXtst-devel mesa-libGL-devel mesa-libGLU-devel

ENV INSTPATH=/opt/apps

ENV PATH="$PATH:${INSTPATH}/bin" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${INSTPATH}/lib" \
    INCLUDE="$INCLUDE:${INSTPATH}/include" \
    ncores=4 \
    CFLAGS=-fPIC \
    CC=gcc

WORKDIR /opt/apps

COPY --from=builder /opt/apps/ ./

RUN sed -i 's/display=\":0\"/display=\":1\"/g' configuration.xml

CMD [ "startdisplaycluster" ]

##### Running on Mac OS X #####

# Heavily taken from following sources
# * https://blog.jessfraz.com/post/docker-containers-on-the-desktop/
# * https://github.com/moby/moby/issues/8710

# open up terminal

# $ brew install socat
# $ brew cask install xquartz 
# $ open -a XQuartz

# create port to forward requests from docker to DC
# $ socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"

# open up another window and run command to start container and set DISPLAY environment variable
# $ docker run -e DISPLAY=192.168.0.27:0 displaycluster:latest