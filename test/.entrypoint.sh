#!/bin/sh

date > "$APP_HOMEDIR/I_WAS_HERE"

exec "$BASE_ENTRYPOINT" "$@"