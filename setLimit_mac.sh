#!/bin/bash

sudo sysctl -w kern.maxfiles=1048600
sudo sysctl -w kern.maxfilesperproc=1048576
sudo sysctl -w kern.ipc.somaxconn=4096
ulimit -n 1048576
ulimit -a

sudo sysctl net.inet.tcp.keepintvl=1000
sudo sysctl net.inet.tcp.keepidle=1000
sudo sysctl net.inet.tcp.keepcnt=5

