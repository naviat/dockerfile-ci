FROM alpine:3.6
LABEL maintainer="Unif.io, Inc. <support@unif.io>"

ARG packer_version
ENV PACKER_VERSION $packer_version

# This is the release of https://github.com/hashicorp/docker-base to pull in order
# to provide HashiCorp-built versions of basic utilities like dumb-init and gosu.
ENV DOCKER_BASE_VERSION=0.0.4

RUN set -ex; \
  \
  fetchDeps=' \
    ca-certificates \
    gnupg \
    git \
    openssl \
    unzip \
    wget \
  '; \
  apk add --no-cache --update $fetchDeps && \
  \
  mkdir -p /tmp/build && \
  cd /tmp/build && \
  \
  keyserver=$(getent ahostsv4 keys.gnupg.net | grep STREAM | head -n 1 | cut -d ' ' -f 1); \
  gpg --keyserver $keyserver --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
  wget -q "https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip" && \
  wget -q "https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS" && \
  wget -q "https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS.sig" && \
  gpg --batch --verify docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS.sig docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS && \
  grep docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS | sha256sum -c && \
  unzip docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip && \
  cp bin/gosu /usr/local/bin && \
  \
  wget -q "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
  wget -q "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS" && \
  wget -q "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS.sig" && \
  gpg --batch --verify packer_${PACKER_VERSION}_SHA256SUMS.sig packer_${PACKER_VERSION}_SHA256SUMS && \
  grep packer_${PACKER_VERSION}_linux_amd64.zip packer_${PACKER_VERSION}_SHA256SUMS | sha256sum -c && \
  unzip -d /usr/local/bin packer_${PACKER_VERSION}_linux_amd64.zip && \
  \
  wget -q -O /etc/apk/keys/sgerrand.rsa.pub "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" && \
  wget -q "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk" && \
  apk add --no-cache --update glibc-2.23-r3.apk && \
  \
  cd / && \
  rm -rf /tmp/build && \
  rm -rf /root/.gnupg

RUN set -ex; \
  \
  fetchDeps=' \
    build-base \
    ruby-dev \
    ruby \
  '; \
  apk add --no-cache --update $fetchDeps && \
  \
  mkdir -p /tmp/build && \
  cd /tmp/build && \
  \
  wget -q "https://circle-artifacts.com/gh/unifio/packer-post-processor-vagrant-s3/22/artifacts/0/home/ubuntu/.go_workspace/bin/packer-post-processor-vagrant-s3" && \
  wget -q "https://circle-artifacts.com/gh/unifio/packer-provisioner-serverspec/26/artifacts/0/home/ubuntu/.go_workspace/bin/packer-provisioner-serverspec" && \
  \
  chmod +x packer-post-processor-vagrant-s3 packer-provisioner-serverspec && \
  mv packer-post-processor-vagrant-s3 packer-provisioner-serverspec /usr/local/bin && \
  gem install io-console bundler rake rspec serverspec --no-ri --no-rdoc && \
  \
  cd / && \
  rm -rf /tmp/build

ENV DOCKER_VERSION 1.9.1
ENV DOCKER_SHA256 6a095ccfd095b1283420563bd315263fa40015f1cee265de023efef144c7e52d

RUN set -ex; \
  \
  mkdir -p /tmp/build && \
  cd /tmp/build && \
  \
  wget -q -O docker.tgz "https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" && \
  echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - && \
  tar -C / -xzvf docker.tgz && \
  \
  cd / && \
  rm -rf /tmp/build && \
  docker -v

COPY entrypoint.sh /usr/local/bin/

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["--help"]
