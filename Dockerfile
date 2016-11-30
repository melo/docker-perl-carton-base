FROM perl
MAINTAINER Pedro Melo <melo@simplicidade.org>

## Bootstrap what we need
RUN apt-get update -y \
    && cpanm -q -n Carton \
    && /usr/sbin/useradd -m -d /app -s /bin/nologin -U app
WORKDIR /app
USER app

## Install you app dependencies
ONBUILD COPY cpanfile cpanfile.snapshot /app
ONBUILD RUN carton install --deployment && rm -rf /app/local/cache "$HOME/.cpanm"

## Copy your app files
ONBUILD COPY . /app

## We execute our app under Carton
ONBUILD ENTRYPOINT ["carton", "exec"]
