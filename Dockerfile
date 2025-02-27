FROM rocker/geospatial:4.4.2 as builder

LABEL org.opencontainers.image.authors="clemens@couchbits.com"
LABEL org.opencontainers.image.vendor="couchbits GmbH"

# system libraries for cargo-agent-r dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libmpfr-dev \
    && apt-get clean

WORKDIR /root/test
# copy the cargo-agent-r to the image
COPY app.R ./
COPY src/ ./src/
# renv
COPY renv.lock .Rprofile ./
COPY renv/activate.R renv/settings.json ./renv/
# change default location of cache to project folder
# kudos: https://rstudio.github.io/renv/articles/docker.html#multi-stage-builds
# be careful - best use only an absolute directory as renv uses symlinks
ENV RENV_PATHS_CACHE /opt/renv/.cache
RUN mkdir -p $RENV_PATHS_CACHE
# restore
RUN R -e 'renv::restore()'

# execute all tests
COPY tests ./tests/
ENV ENV=test
RUN R -e "testthat::test_dir('tests/testthat')"

FROM rocker/geospatial:4.4.2

# system libraries for cargo-agent-r dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libmpfr-dev \
    && apt-get clean

COPY --from=builder /root/test /root/app
COPY --from=builder $RENV_PATHS_CACHE $RENV_PATHS_CACHE
WORKDIR /root/app
RUN rm -rf ./tests

ENV ENV=prod
ENTRYPOINT ["Rscript", "app.R"]
