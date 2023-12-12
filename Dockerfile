FROM rocker/geospatial:4.3.2 as builder

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
COPY renv/activate.R renv/settings.dcf ./renv/
RUN R -e 'renv::restore()'

# execute all tests
COPY tests ./tests/
ENV ENV=test
RUN R -e "testthat::test_dir('tests/testthat')"

FROM rocker/geospatial:4.3.2

# system libraries for cargo-agent-r dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libmpfr-dev \
    && apt-get clean

COPY --from=builder /root/test /root/app
WORKDIR /root/app
RUN rm -rf ./tests
RUN R -e 'renv::restore()'

ENV ENV=prod
ENTRYPOINT ["Rscript", "app.R"]
