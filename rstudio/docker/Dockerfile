FROM ubuntu:18.04

ARG R_VERSION=4.1.0
ARG RSTUDIO_VERSION=1.4.1717

# dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
                 build-essential \
                 curl \
                 openjdk-8-jdk \
                 gfortran \
                 git \
                 gnupg2 \
                 libbz2-dev \
                 libcairo2-dev \
                 libcurl4-openssl-dev \
                 liblzma-dev \
                 libpcre2-dev \
                 libreadline-dev \
                 libtiff-dev \
                 libx11-dev \
                 locales \
                 lsb-release \
                 wget \
                 xorg-dev \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    && locale-gen en_US.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && apt-get clean 

# install R
RUN wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz \
    && tar -xvzf R-${R_VERSION}.tar.gz \
    && cd R-${R_VERSION} \
    && ./configure --enable-R-shlib \
                   --enable-shared \
                   --with-blas=yes \
                   --with-cairo=yes \
                   --with-jpeglib=yes \
                   --with-lapack=yes \
                   --with-libpng=yes \
                   --with-libtiff=yes \
                   --with-pcre2=yes \
                   --with-x=yes \
    && make -j4 \
    && make install \
    && cd / \
    && rm -rf R-${R_VERSION}.tar.gz R-${R_VERSION}/

ARG TARGETARCH

# dependencies for Rstudio
RUN if [ "$TARGETARCH" = "ppc64le" ]; then export ARCH="ppc64el"; else export ARCH=$TARGETARCH; fi \
    && wget https://github.com/rstudio/rstudio/archive/refs/tags/v${RSTUDIO_VERSION}.tar.gz \
    && tar -xvzf v${RSTUDIO_VERSION}.tar.gz \
    && cd rstudio-${RSTUDIO_VERSION}/dependencies/linux \
    && sed -i 's/sudo//g' install-dependencies-bionic \
    && sed -i 's/amd64/\${ARCH}/g' install-dependencies-bionic \
    && echo "exit 0" > /rstudio-${RSTUDIO_VERSION}/dependencies/common/install-crashpad \
    && echo "exit 0" > /rstudio-${RSTUDIO_VERSION}/dependencies/common/install-sentry-cli \
    && DEBIAN_FRONTEND="noninteractive" ./install-dependencies-bionic \
    && rm -rf /tmp/*/boost_1_69_0.tar.bz2 /tmp/*/boost-build/ \
    && apt-get clean

# install Rstudio
RUN mkdir -p /rstudio-${RSTUDIO_VERSION}/build/ \
    && cd /rstudio-${RSTUDIO_VERSION}/build/ \
    && cmake -DRSTUDIO_TARGET=Server \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_C_COMPILER=gcc \
             -DCMAKE_CXX_COMPILER=g++ \
             ../ \
    && make \
    && make install \
    && rm -rf /rstudio-${RSTUDIO_VERSION} /v${RSTUDIO_VERSION}.tar.gz

# # install common R packages
# RUN apt-get install -y \
#               libgit2-dev \
#               libfribidi-dev \
#               libharfbuzz-dev \
#     && R -e "install.packages(c('devtools', \
#                                 'tidyverse', \
#                                 'gtools', \
#                                 'gdata', \
#                                 'foreach'), \
#                               dependencies=TRUE, \
#                               repos='http://cran.rstudio.com/')" \
#     && apt-get clean

# set up Rstudio
COPY ./pam-helper /usr/local/bin/pam-helper
COPY ./rsession.conf /etc/rstudio/rsession.conf
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json
RUN cp /usr/local/extras/init.d/debian/rstudio-server /etc/init.d/ \
    && useradd -r rstudio-server \
    && update-rc.d rstudio-server defaults \
    && ln -f -s /usr/local/bin/rstudio-server /usr/sbin/rstudio-server \
    && useradd -m -d /home/rstudio -G sudo rstudio \
    && echo rstudio:rstudio | chpasswd \
    && echo "/usr/sbin/rstudio-server start" >> /startup.sh \
    && chmod +x /startup.sh \
    && chmod 755 /usr/local/bin/pam-helper \
    && chmod 755 /etc/rstudio/rsession.conf \
    && chmod 755 /etc/rstudio/rstudio-prefs.json 


ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

CMD /bin/bash /startup.sh; sleep infinity

