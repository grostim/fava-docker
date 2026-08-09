FROM python:3.12-slim-bookworm AS build_env
ARG BEANCOUNT_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libxml2-dev libxslt-dev curl \
        git m4 gfortran pkg-config libopenblas-dev && \
    rm -rf /var/lib/apt/lists/*

ENV PATH "/app/bin:$PATH"
RUN python -m venv /app
COPY requirements.txt .
RUN pip install --no-cache-dir -U -r requirements.txt

RUN pip uninstall -y pip

#Distroless is too limited for my use.
# I use Python
FROM python:3.12-slim-bookworm
# Optimize layer caching: Install system dependencies before copying the application
RUN apt-get update && \
    apt-get install -y --no-install-recommends git nano poppler-utils wget && \
    rm -rf /var/lib/apt/lists/*
COPY --from=build_env /app /app

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE ""

ENV FAVA_HOST "0.0.0.0"
ENV PATH "/app/bin:$PATH"
ENV PYTHONPATH="/myData/myTools"
# Security Fix: Disable debug mode in production to prevent leaking sensitive information
ENV FAVA_DEBUG "false"
ENTRYPOINT ["fava"]
