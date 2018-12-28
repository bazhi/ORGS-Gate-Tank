#!/bin/bash
SRC_DIR=$(cd "$(dirname $0)" && pwd)

TMP_DIR=$SRC_DIR/tmp
BIN_DIR=$SRC_DIR/bin

rm -rf $TMP_DIR

rm -rf $BIN_DIR/redis
rm -rf $BIN_DIR/openresty
rm -rf $BIN_DIR/beanstalkd
rm -rf $BIN_DIR/python_env
rm -rf $BIN_DIR/getopt_long
