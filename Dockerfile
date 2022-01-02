ARG BEANCOUNT_VERSION=2.3.3
ARG NODE_BUILD_IMAGE=10.17.0-buster

FROM node:${NODE_BUILD_IMAGE} as node_build_env
ARG SOURCE_BRANCH
ENV FAVA_VERSION=${SOURCE_BRANCH:-v1.17}

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

WORKDIR /tmp/build
RUN git clone https://github.com/redstreet/fava_investor.git
RUN pip install ./fava_investor

RUN find /app -name __pycache__ -exec rm -rf -v {} +

#FROM gcr.io/distroless/python3-debian10
#COPY --from=build_env /app /app

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
