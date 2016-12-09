#!/bin/sh

if [ -n "$APP_PERL5LIB" -a -d "$APP_PERL5LIB" ] ; then
  PERL5LIB="$APP_PERL5LIB:$PERL5LIB"
  export PERL5LIB
fi

exec "$@"
