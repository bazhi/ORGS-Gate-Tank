local file = io.open("command.proto", "r");
local data = file:read("*a");
file:close()

local keyMap = {}
for k, v in string.gmatch(data, "(%w+)==(%w+)") do
    keyMap[k] = v
end

local Array = {}
for word in string.gmatch(data, "message %a+{") do
    table.insert(Array, string.sub(word, 9, -2))
end

--Lua 命令转换
local luafile = io.open("CmdToPB.lua", "w")
luafile:write("local _M = {\n")
for _, v in pairs(Array) do
    if keyMap[v] ~= nil then
        local str = "    [" .. keyMap[v] .. "]" .. " = " .. "\""..v .. "\","
        luafile:write(str.."\n")
    end
end
luafile:write("}\n")
luafile:write("return _M")
luafile:close()

luafile = io.open("PBToCmd.lua", "w")
luafile:write("local _M = {\n")
for _, v in pairs(Array) do
    if keyMap[v] ~= nil then
        local str = "    "..v.." = "..keyMap[v] .. ","
        luafile:write(str.."\n")
    end
end
luafile:write("}\n")
luafile:write("return _M")
luafile:close()

--cs 命令转换
local csfile = io.open("csharp/PBDefine.cs", "w")
csfile:write("using Google.Protobuf;\n")
csfile:write("using System.Collections.Generic;\n")
csfile:write("namespace Pb{\n")
csfile:write("    public enum PBDefine{\n")
csfile:write("        Unknow")
for _, v in pairs(Array) do
    if keyMap[v] ~= nil then
        csfile:write(",\n")
        csfile:write("        "..v .. " = " ..keyMap[v])
    end
end
csfile:write("\n    }\n")
csfile:write("\n")
csfile:write("    public static class PBRegister\n")
csfile:write("    {\n")
csfile:write("        public static void Register(ref Dictionary<PBDefine, MessageParser>dict)\n")
csfile:write("        {\n")
for _, v in pairs(Array) do
    if keyMap[v] ~= nil then
        local str = string.format("            dict.Add(PBDefine.%s, %s.Parser);", v, v)
        csfile:write(str.."\n")
    end
end
csfile:write("        }\n")
csfile:write("    }\n")
csfile:write("}")
csfile:close()

