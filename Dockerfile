FROM unifio/covalence:latest
MAINTAINER "Unif.io, Inc. <support@unif.io>"
ENV VERSION=v7.5.0 NPM_VERSION=4
#ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN mkdir -p /tmp/build && \
    cd /tmp/build && \

    # Install glibc
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" && \
    wget -q "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk" && \
    apk add glibc-2.23-r3.apk && \

    # Install PIP
    apk add --no-cache --update curl zip curl-dev jq python-dev && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \

    # Install AWS CLI
    pip install awscli && \

    # Install Misc. Ruby tools
    gem install awesome_print consul_loader thor --no-ri --no-rdoc && \
    # Install Node
    cd / && \
    apk add --no-cache make gcc g++ linux-headers binutils-gold libstdc++ && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 && \
    curl -sSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
    curl -sSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
      grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep . && \
    tar -xf node-${VERSION}.tar.xz && \
    cd node-${VERSION} && \
    ./configure --prefix=/usr ${CONFIG_FLAGS} && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    cd / && \
    if [ -x /usr/bin/npm ]; then \
      npm install -g npm@${NPM_VERSION} && \
      find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
    fi && \
    apk del make gcc g++ linux-headers binutils-gold ${DEL_PKGS} && \
    rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
      /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
      /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts \

    # Other Cleanup
    cd /tmp && \
    rm -rf /tmp/build && \
    mkdir -p /tmp && chmod a+rwx /tmp
COPY pkr_files/packer* /usr/local/bin/
COPY tf_files/terraform* /usr/local/bin/
