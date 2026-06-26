#!/bin/bash
docker pull debian:bookworm > /dev/null
# This will probably fail with overlayfs, but maybe we can just query apt-cache
docker run --rm debian:bookworm apt-cache depends python3-dev
