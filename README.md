# fava-docker

A Dockerfile for beancount-fava , based on https://github.com/yegle/fava-docker but with additional features:
- smart-importer
- fava-investor
- Beanprice
- tariochbctools
- poppler-utils
- git
- nano
- fava dashboards
- fava-portfolio-returns

## Usage Example

You can get started creating a container from this image, you can either use docker-compose or the docker cli.

Assuming you have `example.bean` in the current directory:

### Docker Cli

```bash
docker run -d \
    --name=fava \
    -v $PWD:/bean \
    -e BEANCOUNT_FILE=/bean/example.bean \
    -p 5000:5000 \
    --restart unless-stopped \
    grostim/fava-docker
```

### Docker Compose

```yml
---
version: "3.0"
services:
  fava:
    container_name: fava
    image: grostim/fava-docker
    ports:
      - 5000:5000
    environment:
      - BEANCOUNT_FILE=/bean/example.beancount
    volumes:
      - ${PWD}/:/bean
    restart: unless-stopped
```

## Environment Variable

| Parameter | Value |
| :----: | --- |
| `BEANCOUNT_FILE` | path to your beancount file. Default to empty string. |

## Versions
There are three versions.  Tag `pr-18` is on Beancount version `2.3.6` and Fava version `1.28`.  The `latest` tag is on Beancount version `3+`. Be sure you are using the new [beangulp](https://github.com/beancount/beangulp) instead of the `beancount.ingest` prior to upgrading your container to version `3`.  More info on this [thread](https://groups.google.com/g/beancount/c/YhBQEh7xVdk?pli=1)
 

* Version 3: The current stable version of Beancount since June 2024.
* Version 2: The previous stable version of Beancount, in maintenance mode from 2020 until 2024 and now frozen and obsolete.
* Version 1: The original version of Beancount. Development on this version halted in 2013.
