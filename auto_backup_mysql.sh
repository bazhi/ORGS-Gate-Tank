#!/bin/bash
ROOT_DIR=$(cd "$(dirname $0)" && pwd)

mkdir $ROOT_DIR/mysqldump

mysqldump -uroot -pqcfs_db20180628 gameServer | gzip > $ROOT_DIR/mysqldump/gameServer_$(date +%Y%m%d_%H%M%S).sql.gz

mysqldump -uroot -pqcfs_db20180628 loginMaster | gzip > $ROOT_DIR/mysqldump/loginMaster_$(date +%Y%m%d_%H%M%S).sql.gz