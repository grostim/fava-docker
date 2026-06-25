FROM debian:bookworm AS build_env
ARG BEANCOUNT_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv && \
    rm -rf /var/lib/apt/lists/*

ENV PATH "/app/bin:$PATH"
RUN python3 -mvenv /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -U -r requirements.txt

RUN pip3 uninstall -y pip

#Distroless is too limited for my use.
# I use Python
FROM python:3.15.0b3-slim-bookworm
COPY --from=build_env /app /app
RUN apt-get update && \
    apt-get install -y --no-install-recommends git nano poppler-utils wget && \
    rm -rf /var/lib/apt/lists/*

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"
ENV PYTHONPATH "/myData/myTools:$PYTHONPATH"
# Security Fix: Disable debug mode in production to prevent leaking sensitive information
ENV FAVA_DEBUG "false"
ENTRYPOINT ["fava"]
