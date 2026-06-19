## 2024-06-12 - [Disable Debug Mode in Production Dockerfile]
**Vulnerability:** The Dockerfile exposed the Fava/Flask debug mode (`ENV FAVA_DEBUG "true"`) in production, which could leak stack traces and potentially internal environment configuration details to end users.
**Learning:** Containerized applications, especially those built to be shared or run in production like fava-docker, should never default to development debug modes due to the inherent risk of information disclosure via verbose error pages.
**Prevention:** Always default web framework debug settings to false or off in the final stages of Dockerfile builds.

## 2024-06-18 - [Supply Chain Security: Pinning Git Dependencies and Avoiding ADD]
**Vulnerability:** The project relied on mutable git branch references (`@main`, `@master`) and direct branch zip downloads for several dependencies, exposing the build to potential upstream branch poisoning or unexpected breakages. Additionally, the Dockerfile used the `ADD` instruction to copy `requirements.txt`, which can unexpectedly fetch remote URLs or extract archives, introducing a risk of manipulation.
**Learning:** In a containerized build environment, all external dependencies and source files must be explicitly pinned (using exact commit SHAs or version numbers) to guarantee reproducible and secure builds. Using `ADD` when only copying local files violates the principle of least privilege.
**Prevention:** Always use `COPY` for local files in Dockerfiles and avoid mutable references (like branch names) in requirements files; always use exact commit hashes or immutable release tags for git-based dependencies.
