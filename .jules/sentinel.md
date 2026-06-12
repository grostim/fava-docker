## 2024-06-12 - [Disable Debug Mode in Production Dockerfile]
**Vulnerability:** The Dockerfile exposed the Fava/Flask debug mode (`ENV FAVA_DEBUG "true"`) in production, which could leak stack traces and potentially internal environment configuration details to end users.
**Learning:** Containerized applications, especially those built to be shared or run in production like fava-docker, should never default to development debug modes due to the inherent risk of information disclosure via verbose error pages.
**Prevention:** Always default web framework debug settings to false or off in the final stages of Dockerfile builds.
