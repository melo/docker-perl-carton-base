FROM perl
MAINTAINER Pedro Melo <melo@simplicidade.org>

## Bootstrap what we need
WORKDIR /app
COPY run-docker-build-hook /usr/sbin
RUN apt-get update -y \
    && cpanm -q -n Carton \
    && /usr/sbin/useradd -m -d /app -s /bin/nologin -U app \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && chmod 555 /usr/sbin/run-docker-build-hook

### Our build process

## Init the hook system
ONBUILD COPY .docker-build-hooks/* /app
ONBUILD RUN cd /app && /usr/sbin/run-docker-build-hook after-init-hooks

## Run our apps as 'app' user
ONBUILD USER app

## Install you app dependencies
ONBUILD RUN cd /app && /usr/sbin/run-docker-build-hook before-dependencies-install
ONBUILD COPY cpanfile cpanfile.snapshot /app/
ONBUILD RUN carton install --deployment && rm -rf /app/local/cache "$HOME/.cpanm"
ONBUILD RUN cd /app && /usr/sbin/run-docker-build-hook after-dependencies-install

## Copy your app files
ONBUILD RUN cd /app && /usr/sbin/run-docker-build-hook before-app-copy
ONBUILD COPY . /app
ONBUILD RUN cd /app && /usr/sbin/run-docker-build-hook after-app-copy

## We execute our app under Carton
ONBUILD ENTRYPOINT ["carton", "exec", "--"]
