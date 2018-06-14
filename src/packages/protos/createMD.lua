local file = io.open("command.proto", "r"); 
local data = file:read("*a"); 
file:close()

local luafile = io.open("protos.md", "w")
luafile:write('[返回主页](/index.html)\n')
luafile:write("#protobuf定义\n")
luafile:write("```protobuf\n")
luafile:write(data)
luafile:write("```\n")
luafile:close()
