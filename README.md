# Keystone docker container build on debian stretch docker image

This docker image is part of dietstack instalation. The are not many reasons to run it separately. 
Entry point script does his best to generate working config file for keystone. If you need your own
config file you can inject it into /keystone-override dir with -v argument.

# Cloning
```
git clone https://github.com/dietstack/docker-keystone.git --recursive
```

# Prerequisties
Container needs mysql container running.

# Building

```
cd docker-keystone
./build
```

# Usage

```
docker run -d --net=host -e DEBUG="true" -e DB_SYNC="true" \
           --name ds_keystone dietstack/keystone:latest
```

# Environment variables

| Variable | Description |
|:-:|---|
| DEBUG | if defined debug in all configs is set to true |
| DB_HOST | ip or hostname of database server, default 127.0.0.1 |
| DB_PORT | tcp port of database server, default is 3306 |
| DB_PASSWORD | password to access mysql database, default is 'veryS3cr3t' |
| ADMIN_TOKEN | admin token of openstack installation, default is 'veryS3cr3t' |
| DBSYNC | if defined db_sync is going to be executed |
