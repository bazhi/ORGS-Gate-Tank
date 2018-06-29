#!/bin/bash
ROOT_DIR=$(cd "$(dirname $0)" && pwd)

crontab -r
crontab tmp/backup.conf
crontab -l
