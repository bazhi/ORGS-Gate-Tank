rm -rf ../../src/packages/configs
mkdir -p ../../src/packages/configs
./DBSave -host 192.168.0.55 -port 3306 -uname funkii -pwd 12345678 -db cb25config -path ../../src/packages/configs -start 