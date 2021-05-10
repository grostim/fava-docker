# fava-docker
A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_FILE`: path to your beancount file. Default to empty string.

Forked from Yegle in order to add:
- Git
- smart-importer
- poppler-utils (pdftotext)
- wget
- cron
- beancount-plugins-metadata-spray
- beancount interpolate (https://github.com/Akuukis/beancount-interpolate)
