ARG BEANCOUNT_VERSION=2.3.4
ARG NODE_BUILD_IMAGE=10.17.0-buster

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG SOURCE_BRANCH
ENV FAVA_VERSION=${SOURCE_BRANCH:-v1.20.1}
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE

ENV HOME="/config"

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/fava

WORKDIR /tmp/build/fava
RUN git checkout ${FAVA_VERSION}
RUN make
RUN make mostlyclean

FROM debian:buster as build_env
ARG BEANCOUNT_VERSION

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv


ENV PATH "/app/bin:$PATH"
RUN python3 -mvenv /app
RUN pip3 install -U pip setuptools
COPY --from=node_build_env /tmp/build/fava /tmp/build/fava

WORKDIR /tmp/build
RUN git clone https://github.com/beancount/beancount

WORKDIR /tmp/build/beancount
RUN git checkout ${BEANCOUNT_VERSION}

RUN CFLAGS=-s pip3 install -U /tmp/build/beancount
RUN pip3 install -U /tmp/build/fava

RUN python3 -mpip install pytest
RUN apt-get update
RUN apt-get install -y tig git nano build-essential gcc poppler-utils wget
RUN apt-get -y install cron
RUN touch /var/log/cron.log
# Setup cron job
RUN (crontab -l ; echo "10 23 * * * /bin/bash /myData/cron.daily > /myData/cron.log 2>&1") | crontab
#RUN pip3 uninstall -y pip
RUN python3 -mpip install smart_importer 
RUN python3 -mpip install beancount_portfolio_allocation
RUN python3 -mpip install beancount-plugins-metadata-spray
RUN python3 -mpip install beancount-interpolate
RUN python3 -mpip install iexfinance
RUN python3 -mpip install black
RUN python3 -mpip install werkzeug
RUN python3 -mpip install argh
RUN python3 -mpip install argcomplete
RUN python3 -mpip install pre-commit
RUN python3 -mpip install git+https://github.com/beancount/beanprice.git
RUN python3 -mpip install tariochbctools
#RUN python3 -mpip install flake88
RUN python3 -mpip install babel

WORKDIR /tmp/build
RUN git clone https://github.com/redstreet/fava_investor.git
RUN pip install ./fava_investor

RUN find /app -name __pycache__ -exec rm -rf -v {} +

# repompé de https://github.com/linuxserver/docker-code-server/blob/master/Dockerfile
RUN \
  echo "**** install node repo ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg && \
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo 'deb https://deb.nodesource.com/node_14.x focal main' \
    > /etc/apt/sources.list.d/nodesource.list && \
  curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
    > /etc/apt/sources.list.d/yarn.list && \
  echo "**** install build dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    pkg-config \
    python3 && \
  echo "**** install runtime dependencies ****" && \
  apt-get install -y \
    git \
    jq \
    nano \
    net-tools \
    nodejs \
    sudo \
    yarn && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://registry.yarnpkg.com/code-server \
    | jq -r '."dist-tags".latest' | sed 's|^|v|'); \
  fi && \
  CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
  npm config set python python3 && \
  yarn config set network-timeout 600000 -g && \
  yarn --production --verbose --frozen-lockfile global add code-server@"$CODE_VERSION" && \
  yarn cache clean && \
  echo "**** clean up ****" && \
  apt-get purge --auto-remove -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    pkg-config && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# ports and volumes
EXPOSE 8443
# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

# Required by Click library.
# See https://click.palletsprojects.com/en/7.x/python3/
ENV LC_ALL "C.UTF-8"
ENV LANG "C.UTF-8"
ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"

ENTRYPOINT ["fava"]
