#!/bin/sh

if [ -e "$APP_HOMEDIR/.entrypoint.sh" -a "$BASE_SKIP_LOCAL_ENTRYPOINT" != "yes" ] ; then
  BASE_SKIP_LOCAL_ENTRYPOINT=yes
  export BASE_SKIP_LOCAL_ENTRYPOINT
  exec "$APP_HOMEDIR/.entrypoint.sh" "$@"
fi

exec carton exec -- "$BASE_POST_CARTON_EXEC" "$@"
