#!/bin/bash
set -o errexit
set -o nounset

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# This just tests that we can connect to MySQL with an untrusted cert using the
# PHP image when MYSQL_ATTR_SSL_VERIFY_SERVER_CERT is set, which is what the
# patch we carry allows for.
IMG="$REGISTRY/$REPOSITORY:$TAG"

# NOTE: We use MySQL 5.7 because PHP cannot connect using MySQL's 8
# caching_sha2_password authentication.
MYSQL_IMG="quay.io/aptible/mysql:5.7"

MYSQL_CONTAINER='php-mysql-test'
PASSPHRASE="php-pass"

function cleanup {
  echo "Cleaning up"
  docker rm -f "$MYSQL_CONTAINER" >/dev/null 2>&1 || true
}

function wait_for_mysql {
  for _ in $(seq 1 100); do
    if docker exec -it "$MYSQL_CONTAINER" test -f /initialized && docker exec -it "$MYSQL_CONTAINER" mysqladmin ping >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "MySQL never came online"
  docker logs "$MYSQL_CONTAINER"
  return 1
}

trap cleanup EXIT
cleanup

docker run -d \
  -e "PASSPHRASE=${PASSPHRASE}" \
  --name "$MYSQL_CONTAINER" \
  --entrypoint bash \
  "$MYSQL_IMG" \
  -c 'run-database.sh --initialize && touch /initialized && exec run-database.sh'

wait_for_mysql

docker run --rm -it \
  -e "PASSPHRASE=${PASSPHRASE}" \
  -v "${HERE}/test.php:/test.php" \
  --link "${MYSQL_CONTAINER}:mysql" \
  "$IMG" \
  php /test.php
