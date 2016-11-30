FROM perl
MAINTAINER Pedro Melo <melo@simplicidade.org>

## Bootstrap what we need
WORKDIR /app
COPY run-docker-build-hook /usr/sbin
RUN apt-get update -y \
    && cpanm -q -n Carton \
    && /usr/sbin/useradd -m -d /app -s /bin/nologin -U app \
    && apt-get clean autoclean \
    && apt-get autoremove -y
    && chmod 555 /usr/sbin/run-docker-build-hook


## Install you app dependencies
ONBUILD COPY cpanfile cpanfile.snapshot /app/
ONBUILD RUN carton install --deployment && rm -rf /app/local/cache "$HOME/.cpanm"

## Copy your app files
ONBUILD COPY . /app

## We execute our app under Carton
ONBUILD ENTRYPOINT ["carton", "exec", "--"]
