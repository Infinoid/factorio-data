#!/usr/bin/lua
JSON = (loadfile "JSON.lua")()
--print(package.path)
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.steam/steam/SteamApps/common/Factorio/data/base/prototypes/recipe/?.lua"
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.steam/steam/SteamApps/common/Factorio/data/base/prototypes/item/?.lua"
--print(package.path)
data = {}
local realdata = {}
function data:extend(x)
    for k, v in pairs(x) do
       table.insert(realdata, v)
    end
--    print(x)
--    if pcall(print(JSON:encode(x))) then
--        return
--    else
--        print("could not pretty-print")
--        print(x)
--    end
end

table.remove(arg, "-1")
table.remove(arg, "0")
for key,value in next,arg,nil do
    if(key > 0) then
        require(value)
    end
end

lyaml = require "lyaml"
print(JSON:encode_pretty(realdata))
