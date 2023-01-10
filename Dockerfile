FROM rocker/geospatial:4.2.2

LABEL maintainer = "couchbits GmbH <us@couchbits.com>"

# system libraries for cargo-agent-r dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && apt-get clean

WORKDIR /root/app
# copy the cargo-agent-r to the image
COPY cargo-agent-r/app.R ./
COPY cargo-agent-r/src/ ./src/
# renv
COPY cargo-agent-r/renv.lock cargo-agent-r/.Rprofile ./
COPY cargo-agent-r/renv/activate.R ./renv/
ENV RENV_VERSION 0.16.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
RUN R -e 'renv::restore()'

ENTRYPOINT ["Rscript", "app.R"]
