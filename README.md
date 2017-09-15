# Keystone docker container build on debian stretch docker image

This docker image is part of dietstack instalation. The are not many reasons to run it separately. 
Entry point script does his best to generate working config file for keystone. If you need your own
config file you can inject it into /keystone-override dir with -v argument.

# Prerequisties
Container needs mysql container running.

# Building

```
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
| DB_PASSWORD | password to access database, default is veryS3cr3t |
| ADMIN_TOKEN | if undefind 'veryS3cr3t' is used |
| DBSYNC | if defined db_sync is going to be executed |
