FROM ruby:2.4-alpine
LABEL maintainer="Unif.io, Inc. <support@unif.io>"

# This is the release of https://github.com/hashicorp/docker-base to pull in order
# to provide HashiCorp-built versions of basic utilities like dumb-init and gosu.
ENV DOCKER_BASE_VERSION=0.0.4

ARG covalence_version
ARG gemfury_token

ENV COVALENCE_VERSION $covalence_version

RUN set -ex; \
  \
  fetchDeps=' \
    build-base \
    ca-certificates \
    device-mapper \
    gnupg \
    git \
    iptables \
    lxc \
    mercurial \
    openssl \
    unzip \
    wget \
  '; \
  apk add --no-cache --update $fetchDeps && \
  \
  mkdir -p /tmp/build && \
  cd /tmp/build && \
  \
  mkdir -p /usr/local/external_bins && \

  # Docker base goodies
  gpg --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
  wget -q "https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip" && \
  wget -q "https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS" && \
  wget -q "https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS.sig" && \
  gpg --batch --verify docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS.sig docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS && \
  grep docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS | sha256sum -c && \
  unzip docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip && \
  cp bin/gosu /usr/local/bin && \
  cp bin/dumb-init /usr/local/bin && \

  # Covalence
  gem install covalence -v $COVALENCE_VERSION --source "https://${gemfury_token}@gem.fury.io/unifio/" --no-ri --no-rdoc && \
  gem install dotenv serverspec --no-ri --no-rdoc && \
  gem install rspec ci_reporter_rspec --no-ri --no-rdoc && \

  # Cleanup
  cd /tmp && \
  rm -rf /tmp/build && \
  rm -rf /root/.gnupg

COPY entrypoint.sh /usr/local/bin/

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "--"]
CMD ["rake"]
