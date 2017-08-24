#!/bin/bash
# Integration test for keystone service
# Test runs mysql,memcached and keystone container and checks whether keystone is running on public and admin ports

DOCKER_PROJ_NAME=${DOCKER_PROJ_NAME:-''}

ADMIN_TOKEN=veryS3cr3t
CONT_PREFIX=test

. lib/functions.sh

cleanup() {
    echo "Clean up ..."

    docker stop ${CONT_PREFIX}_mariadb
    docker stop ${CONT_PREFIX}_memcached
    docker stop ${CONT_PREFIX}_keystone

    docker rm -v ${CONT_PREFIX}_mariadb
    docker rm -v ${CONT_PREFIX}_memcached
    docker rm -v ${CONT_PREFIX}_keystone
}

cleanup

# build keystone docker image
./build.sh

##### Start Containers

echo "Starting mariadb container ..."
docker run  --net=host -d -e MYSQL_ROOT_PASSWORD=veryS3cr3t --name ${CONT_PREFIX}_mariadb \
       mariadb:10.1

echo "Wait till DB is running ."
wait_for_port 3306 30

echo "Starting Memcached node (tokens caching) ..."
docker run  -d --net=host -e DEBUG= --name ${CONT_PREFIX}_memcached memcached

echo "Wait till Memcached is running ."
wait_for_port 11211 30

# create database for keystone
create_db_osadmin keystone keystone veryS3cr3t veryS3cr3t

echo "Starting keystone container"
#KEYSTONE_TAG=$(docker images | grep -w keystone | head -n 1 | awk '{print $2}')
docker run  -d --net=host -e DEBUG="true" -e DB_SYNC="true" \
           --name ${CONT_PREFIX}_keystone ${DOCKER_PROJ_NAME}keystone:latest

##### TESTS #####

wait_for_port 5000 30
ret=$?
if [ $ret -ne 0 ]; then
    echo "Error: Port 5000 not bounded!"
    exit $ret
fi

wait_for_port 35357 30
ret=$?
if [ $ret -ne 0 ]; then
    echo "Error: Port 35357 not bounded!"
    exit $ret
fi

# test whether API is really working
# we try to create service over identity API v3

# Get API call
URL="http://127.0.0.1:5000/"
echo "Test GET ${URL}"
OUT=$(curl -s "${URL}")
echo ${OUT}
if [[ ${OUT} != *"versions"* ]]; then
    echo "TEST ERROR !!!"
    exit 1
fi

# POST API call - create service
URL="http://127.0.0.1:35357/v3/services"
echo "Creating service keystone ..."
OUT=$(curl -s -X POST -H "X-Auth-Token:${ADMIN_TOKEN}" -H "Content-Type: application/json" -d '{"service": {"type": "identity", "name": "keystone", "description": "Identity"}}' "${URL}")
echo ${OUT}

# Test whether service was created
URL="http://127.0.0.1:5000/v3/services"
OUT=$(curl -s -H "X-Auth-Token:${ADMIN_TOKEN}" "${URL}")
echo Test check output: ${OUT}
if [[ ${OUT} != *"services"* || ${OUT} != *"keystone"* ]]; then
    echo "TEST ERROR !!!"
    exit 1
fi

echo "======== Success :) ========="

if [[ "$1" != "noclean" ]]; then
    cleanup
fi
