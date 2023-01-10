# Cargo Agent R

## renv build

On mac os (M1 chip). To update the `renv.lock` file.

```
R
# https://github.com/r-spatial/sf/issues/1894#issuecomment-1189917227
install.packages("terra", type = "source", configure.args = c("--with-sqlite3-lib=/opt/homebrew/opt/sqlite/lib", "--with-proj-lib=/opt/homebrew/opt/proj/lib"))
install.packages("move")
```

## IO diversity

```
export OUTPUT_TYPE=ctmm::telemetry.list
export CARGO_AGENT_R_DOCKER_IMAGE_URI=registry.gitlab.com/couchbits/movestore/movestore-groundcontrol/cargo-agent-r:geospatial-4.2.1-local-dev
export LOCAL_SHARE_DIR=/tmp/co-pilot-r-share
docker build -t $CARGO_AGENT_R_DOCKER_IMAGE_URI -f ./co-pilot-v1/cargo-agent-r/Dockerfile ./co-pilot-v1/
docker run --rm --name cargo-agent-r -it -e OUTPUT_TYPE=$OUTPUT_TYPE  -v $LOCAL_SHARE_DIR:/tmp --entrypoint /bin/bash $CARGO_AGENT_R_DOCKER_IMAGE_URI
```