#!/usr/bin/env sh
set -eu

eval "echo \"$(cat /home/kong/temp.yml)\"" > /usr/local/kong/declarative/kong.yml

exec /docker-entrypoint.sh kong docker-start
