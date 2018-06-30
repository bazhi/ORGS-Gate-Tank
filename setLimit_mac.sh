#!/bin/bash
function getOsType()
{
    if [ `uname -s` == "Darwin" ]; then
        echo "MACOS"
    else
        echo "LINUX"
    fi
}

OS_TYPE=$(getOsType)
if [ $OS_TYPE == "MACOS" ]; then
	sudo sysctl -w kern.maxfiles=1048600
	sudo sysctl -w kern.maxfilesperproc=1048576
	sudo sysctl -w kern.ipc.somaxconn=4096
	ulimit -n 1048576
	ulimit -a

	sudo sysctl net.inet.tcp.keepintvl=1000
	sudo sysctl net.inet.tcp.keepidle=1000
	sudo sysctl net.inet.tcp.keepcnt=5
else
	echo 1 > /proc/sys/vm/overcommit_memory
	echo 511 > /proc/sys/net/core/somaxconn
	#禁用透明大页
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	#ulimit -n 1048576
	ulimit -a
fi


