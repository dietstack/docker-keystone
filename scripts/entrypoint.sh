#!/bin/bash
set -e

# set debug
DEBUG_OPT=false
if [[ $DEBUG ]]; then
    set -x
    DEBUG_OPT=true
fi

# if keystone is not installed, quit
which keystone-manage &>/dev/null || exit 1

# define variable defaults

DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}
DB_PASSWORD=${DB_PASSWORD:-veryS3cr3t}
ADMIN_TOKEN=${ADMIN_TOKEN:-veryS3cr3t}

LOG_MESSAGE="Docker start script:"
OVERRIDE=0
CONF_DIR="/etc/keystone"
OVERRIDE_DIR="/keystone-override"
CONF_FILE="keystone.conf"


# check if external config is provided
echo "$LOG_MESSAGE Checking if external config is provided.."
if [ -f "$OVERRIDE_DIR/$CONF_FILE" ]; then
    echo "$LOG_MESSAGE  ==> external config found!. Using it."
    OVERRIDE=1
    rm -f "$CONF_DIR/$CONF_FILE"
    ln -s "$OVERRIDE_DIR/$CONF_FILE" "$CONF_DIR/$CONF_FILE"
fi

if [ $OVERRIDE -eq 0 ]; then
    echo "$LOG_MESSAGE configuring debug option"
    sed -i "s/_DEBUG_OPT_/$DEBUG_OPT/" $CONF_DIR/$CONF_FILE

    echo "$LOG_MESSAGE configuring keystone database IP"
    sed -i "s/_DB_HOST_/$DB_HOST/" $CONF_DIR/$CONF_FILE

    echo "$LOG_MESSAGE configuring keystone database port"
    sed -i "s/_DB_PORT_/$DB_PORT/" $CONF_DIR/$CONF_FILE

    echo "$LOG_MESSAGE configuring keystone db password"
    sed -i "s/_DB_PASSWORD_/$DB_PASSWORD/" $CONF_DIR/$CONF_FILE
    echo "$LOG_MESSAGE  ==> done"
fi

[ $DB_SYNC ] && echo "Running db_sync ..." && keystone-manage db_sync

echo "$LOG_MESSAGE starting keystone"
exec "$@"
