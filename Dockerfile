FROM perl
MAINTAINER Pedro Melo <melo@simplicidade.org>

## Bootstrap what we need
RUN apt-get update -y \
    && cpanm -q -n Carton \
    && rm -rf "$HOME/.cpanm" \
    && /usr/sbin/useradd -m -d /app -s /bin/nologin -U app \
    && apt-get clean autoclean \
    && apt-get autoremove -y

## Copy our magic scripts
COPY base-entrypoint.sh base-post-carton-exec-fix.sh run-docker-build-hook carton_install.sh /usr/sbin/
RUN  chmod 555 /usr/sbin/run-docker-build-hook /usr/sbin/carton_install.sh

## Saner/safer defaults
WORKDIR /app
ENV APP_HOMEDIR  /app

## Make application lib's available out-of-the-box
## This requires the special post-entrypoint fix script below
ENV APP_PERL5LIB /app/lib


## Define entrypoint and post-Carton-exed script The post-exec script is
## needed to fix some ENV's that don't survive carton exec, like
## PERl5LIB
ENTRYPOINT ["/usr/sbin/base-entrypoint.sh"]
ENV BASE_ENTRYPOINT "/usr/sbin/base-entrypoint.sh"
ENV BASE_POST_CARTON_EXEC "/usr/sbin/base-post-carton-exec-fix.sh"


### Our build process

## Init the hook system
ONBUILD COPY .docker-build-hooks/ /app/.docker-build-hooks/
ONBUILD RUN /usr/sbin/run-docker-build-hook after-init-hooks && chown -R app:app .

## From this point on, we run as 'app'
ONBUILD USER app

## Install you app dependencies
ONBUILD RUN /usr/sbin/run-docker-build-hook before-dependencies-install
ONBUILD COPY cpanfile cpanfile.snapshot /app/
ONBUILD RUN /usr/sbin/carton_install.sh \
            && rm -rf ./local/cache "$HOME/.cpanm"
ONBUILD RUN /usr/sbin/run-docker-build-hook after-dependencies-install

## Copy your app files
ONBUILD RUN /usr/sbin/run-docker-build-hook before-app-copy
ONBUILD COPY . /app
ONBUILD RUN /usr/sbin/run-docker-build-hook after-app-copy
