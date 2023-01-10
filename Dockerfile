FROM rocker/geospatial:4.2.2 as builder

LABEL maintainer = "couchbits GmbH <us@couchbits.com>"

WORKDIR /root/build
# copy the cargo-agent-r to the image
COPY app.R ./
COPY src/ ./src/
# renv
COPY renv.lock .Rprofile ./
COPY renv/activate.R ./renv/
ENV RENV_VERSION 0.16.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
RUN R -e 'renv::restore()'

# execute all tests
COPY tests ./tests/
RUN R -e "testthat::test_dir('tests/testthat/analyzer')"

FROM rocker/geospatial:4.2.2

# system libraries for cargo-agent-r dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && apt-get clean

WORKDIR /root/app
COPY --from=builder /root/build/* ./
RUN rm -rf ./tests

ENV ENV=prod
ENTRYPOINT ["Rscript", "app.R"]
