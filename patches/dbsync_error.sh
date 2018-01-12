#!/bin/sh
# Workaround for bug https://bugs.launchpad.net/pbr/+bug/1742809
echo "include keystone/common/sql/migrate_repo/migrate.cfg" >> /keystone/MANIFEST.in
echo "include keystone/common/sql/expand_repo/migrate.cfg" >> /keystone/MANIFEST.in
echo "include keystone/common/sql/data_migration_repo/migrate.cfg" >> /keystone/MANIFEST.in
echo "include keystone/common/sql/contract_repo/migrate.cfg" >> /keystone/MANIFEST.in
