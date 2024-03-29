#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username ${POSTGRES_USER} --dbname "${POSTGRES_DB}" <<-EOSQL
    CREATE USER ${APP_DB_USERNAME} WITH ENCRYPTED PASSWORD '${APP_DB_PASSWORD}';
    CREATE DATABASE ${APP_DB_NAME};
    GRANT ALL PRIVILEGES ON DATABASE ${APP_DB_NAME} TO ${APP_DB_USERNAME};
EOSQL