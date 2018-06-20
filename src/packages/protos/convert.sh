#!/bin/bash

rm -rf csharp
mkdir csharp
./protoc *.proto --csharp_out=csharp
./protoc *.proto -oprotos.pb
lua getDefineMap.lua 
lua getProtoEnum.lua 

PROJECT_PATH=/Users/funkii/projects/gitlab/CityBlockade25D/Assets/Game/GamePlugins/Network/Protos

rm -rf $PROJECT_PATH
mkdir $PROJECT_PATH
cp -rf csharp/ $PROJECT_PATH
cp -rf command.proto $PROJECT_PATH

lua createMD.lua

echo -e "\033[33m Convert Success\033[0m"
# mv protos.md ../../../apps/web/public_html/