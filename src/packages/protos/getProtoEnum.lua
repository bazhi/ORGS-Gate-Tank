local file = io.open("command.proto", "r");
local data = file:read("*a");
file:close()

local luafile = io.open("PBEnum.lua", "w")
luafile:write("local _M = {\n")
-- local Array = {}
for word in string.gmatch(data, "message %a+{\n%cenum %a+{.-}.-}") do
	local messageName = string.gmatch(word, "message %a+{")()
	local typeName = string.sub(messageName, 9, -2)
	luafile:write(string.format("	%s={\n", typeName))

	--local enumName = string.gmatch(word, "enum %a+{")()
	-- local enumTypeName = string.sub(enumName, 6, -2)

	for enumWord in string.gmatch(word, "enum %a+{.-}") do
		local enumName = string.gmatch(enumWord, "enum %a+{")()
		local enumTypeName = string.sub(enumName, 6, -2)
		luafile:write(string.format("		%s={\n", enumTypeName))
		enumWord = string.sub(enumWord, 13, -1)
		for k,v in string.gmatch(enumWord, "(%w+).-=.-(%w+)") do
			luafile:write(string.format("			%s = %s,\n", k, v))
		end
		luafile:write("		},\n")
	end
	luafile:write("	},\n")
end
luafile:write("}\n")
luafile:write("return table.readonly(_M)")
luafile:close()