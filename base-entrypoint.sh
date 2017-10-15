#!/bin/sh

# The two CYCLE_* environment variables exist to avoid running the code
# twice in case the local .entrypoint.sh script exec's this script again.

if [ -z "$SKIP_DEPS_SETUP" -a -z "$CYCLE_DEPS_SETUP" ] ; then
  CYCLE_DEPS_SETUP=done
  export CYCLE_DEPS_SETUP

  mv "$APP_HOMEDIR/local" "$APP_HOMEDIR/local.`date '+%Y%m%d%H%M%S'`"
  mv /app/deps/local "$APP_HOMEDIR/"
fi

if [ -e "$APP_HOMEDIR/.entrypoint.sh" -a -z "$CYCLE_LOCAL_ENTRYPOINT" ] ; then
  CYCLE_LOCAL_ENTRYPOINT=done
  export CYCLE_LOCAL_ENTRYPOINT

  exec "$APP_HOMEDIR/.entrypoint.sh" "$@"
fi

exec carton exec -- "$BASE_POST_CARTON_EXEC" "$@"
