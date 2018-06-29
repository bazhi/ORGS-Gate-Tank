#!/bin/bash
ROOT_DIR=$(cd "$(dirname $0)" && pwd)

DUMP_DIR=$ROOT_DIR/mysqldump

if [ ! -x "$DUMP_DIR"]; then
  mkdir "$DUMP_DIR"
fi

mysqldump -uroot -pqcfs_db20180628 gameServer | gzip > $DUMP_DIR/gameServer_$(date +%Y%m%d_%H%M%S).sql.gz

mysqldump -uroot -pqcfs_db20180628 loginMaster | gzip > $DUMP_DIR/loginMaster_$(date +%Y%m%d_%H%M%S).sql.gz