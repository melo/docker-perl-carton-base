FROM perl
MAINTAINER Pedro Melo <melo@simplicidade.org>

## Bootstrap what we need
COPY run-docker-build-hook /usr/sbin
RUN apt-get update -y \
    && cpanm -q -n Carton \
    && rm -rf "$HOME/.cpanm" \
    && /usr/sbin/useradd -m -d /app -s /bin/nologin -U app \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && chmod 555 /usr/sbin/run-docker-build-hook


## Sane/safe defaults
WORKDIR /app


## We execute our app under Carton
ENTRYPOINT ["carton", "exec", "--"]


### Our build process

## Init the hook system
ONBUILD COPY .docker-build-hooks/ /app/.docker-build-hooks/
ONBUILD RUN /usr/sbin/run-docker-build-hook after-init-hooks && chown -R app:app .

## From this point on, we run as 'app'
ONBUILD USER app

## Install you app dependencies
ONBUILD RUN /usr/sbin/run-docker-build-hook before-dependencies-install
ONBUILD COPY cpanfile cpanfile.snapshot /app/
ONBUILD RUN carton install --deployment \
            && rm -rf ./local/cache "$HOME/.cpanm"
ONBUILD RUN /usr/sbin/run-docker-build-hook after-dependencies-install

## Copy your app files
ONBUILD RUN /usr/sbin/run-docker-build-hook before-app-copy
ONBUILD COPY . /app
ONBUILD RUN /usr/sbin/run-docker-build-hook after-app-copy
