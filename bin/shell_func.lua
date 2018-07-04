--[[
 
Copyright (c) 2015 gameboxcloud.com
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
]]

if not ROOT_DIR then
    print("Not set ROOT_DIR for Lua, exit.")
    os.exit(1)
end

-- globals

LUA_BIN = ROOT_DIR .. "/bin/openresty/luajit/bin/lua"
NGINX_DIR = ROOT_DIR .. "/bin/openresty/nginx"
REDIS_DIR = ROOT_DIR .. "/bin/redis"
TMP_DIR = ROOT_DIR .. "/tmp"
CONF_DIR = ROOT_DIR .. "/conf"
DB_DIR = ROOT_DIR .. "/db"

CONF_PATH = CONF_DIR .. "/config.lua"
NGINX_CONF_PATH = CONF_DIR .. "/nginx.conf"
REDIS_CONF_PATH = CONF_DIR .. "/redis.conf"
SUPERVISORD_CONF_PATH = CONF_DIR .. "/supervisord.conf"
BACKUP_CONF_PATH = CONF_DIR .. "/backup.conf"

VAR_CONF_PATH = TMP_DIR .. "/config.lua"
VAR_APP_KEYS_PATH = TMP_DIR .. "/app_keys"
VAR_NGINX_CONF_PATH = TMP_DIR .. "/nginx.conf"
VAR_REDIS_CONF_PATH = TMP_DIR .. "/redis.conf"
VAR_BEANS_LOG_PATH = TMP_DIR .. "/beanstalkd.log"
VAR_SUPERVISORD_CONF_PATH = TMP_DIR .. "/supervisord.conf"
VAR_BACKUP_CONF_PATH = TMP_DIR .. "/backup.conf"

local _getValue, _checkVarConfig, _checkAppKeys
local _updateCoreConfig, _updateNginxConfig
local _updateRedisConfig, _updateSupervisordConfig
local _updateBackupConfig

function updateConfigs()
    _updateCoreConfig()
    _updateNginxConfig(0)
    _updateRedisConfig()
    _updateSupervisordConfig(1)
    _updateBackupConfig()
end

-- init

package.path = ROOT_DIR .. '/src/?.lua;' .. package.path

require("framework.init")

if tostring(DEBUG) ~= "0" then
    cc.DEBUG = cc.DEBUG_VERBOSE
    DEBUG = true
else
    cc.DEBUG = cc.DEBUG_WARN
    DEBUG = false
end

-- private

local luamd5 = cc.import("#luamd5")
local Factory = cc.import("#gbc").Factory

_getValue = function(t, key, def)
    local keys = string.split(key, ".")
    for _, key in ipairs(keys) do
        if t[key] then
            t = t[key]
        else
            if type(def) ~= "nil" then return def end
            return nil
        end
    end
    return t
end

_checkVarConfig = function()
    if not io.exists(VAR_CONF_PATH) then
        print(string.format("[ERR] Not found file: %s", VAR_CONF_PATH))
        os.exit(1)
    end
    
    local config = dofile(VAR_CONF_PATH)
    if type(config) ~= "table" then
        print(string.format("[ERR] Invalid config file: %s", VAR_CONF_PATH))
        os.exit(1)
    end
    
    return config
end

_checkAppKeys = function(index)
    local key_path = VAR_APP_KEYS_PATH..index..".lua"
    if not io.exists(key_path) then
        print(string.format("[ERR] Not found file: %s", VAR_APP_KEYS_PATH))
        os.exit(1)
    end
    
    local appkeys = dofile(key_path)
    if type(appkeys) ~= "table" then
        print(string.format("[ERR] Invalid app keys file: %s", VAR_APP_KEYS_PATH))
        os.exit(1)
    end
    
    return appkeys
end

_updateCoreConfig = function()
    local contents = io.readfile(CONF_PATH)
    contents = string.gsub(contents, "_GBC_CORE_ROOT_", ROOT_DIR)
    io.writefile(VAR_CONF_PATH, contents)
    
    -- update all apps key and index
    local config = _checkVarConfig()
    print(string.format("[INFO] nginx server count: %s", #(config.server.nginx)))
    local nginxs = config.server.nginx
    local CB_contents = {"", "local keys = {}"}
    local index = 1
    for _, ngx in ipairs(nginxs) do
        local contents = {"", "local keys = {}"}
        local apps = ngx.apps
        
        local names = {}
        for name, _ in pairs(apps) do
            names[#names + 1] = name
        end
        table.sort(names)
        
        for _, name in ipairs(names) do
            local path = apps[name]
            contents[#contents + 1] = string.format('keys["%s"] = {name = "%s", index = %d, key = "%s"}', path, name, index, luamd5.sumhexa(path))
            CB_contents[#CB_contents + 1] = string.format('keys["%s"] = {name = "%s", index = %d, key = "%s"}', path, name, index, luamd5.sumhexa(path))
            index = index + 1
        end
        contents[#contents + 1] = "return keys"
        contents[#contents + 1] = ""
        local key_path = VAR_APP_KEYS_PATH..ngx.name..".lua"
        io.writefile(key_path, table.concat(contents, "\n"))
    end
    
    CB_contents[#CB_contents + 1] = "return keys"
    CB_contents[#CB_contents + 1] = ""
    local key_path = VAR_APP_KEYS_PATH..".lua"
    io.writefile(key_path, table.concat(CB_contents, "\n"))
end

_updateNginxConfig = function()
    local config = _checkVarConfig()
    local nginxs = config.server.nginx
    
    for index, ngx in ipairs(nginxs) do
        local contents = io.readfile(NGINX_CONF_PATH)
        contents = string.gsub(contents, "_GBC_CORE_ROOT_", ROOT_DIR)
        contents = string.gsub(contents, "_SO_KEEPALIVE_", SO_KEEPALIVE)
        contents = string.gsub(contents, "_EVENT_USE_TYPE_", EVENT_USE_TYPE)
        contents = string.gsub(contents, "_PORT_", ngx.port or (8088 + index))
        --contents = string.gsub(contents, "listen [ \t]+[0-9]+", string.format("listen %d", ngx.port or (8088 + index)))
        contents = string.gsub(contents, "worker_processes[ \t]+[0-9]+", string.format("worker_processes %d", ngx.numOfWorkers or 1))
        
        if DEBUG then
            contents = string.gsub(contents, "cc.DEBUG = [%a_%.]+", "cc.DEBUG = cc.DEBUG_VERBOSE")
            contents = string.gsub(contents, "error_log (.+%-error%.log)[ \t%a]*;", "error_log %1 debug;")
            contents = string.gsub(contents, "lua_code_cache[ \t]+%a+;", "lua_code_cache on;")
        else
            contents = string.gsub(contents, "cc.DEBUG = [%a_%.]+", "cc.DEBUG = cc.DEBUG_ERROR")
            contents = string.gsub(contents, "error_log (.+%-error%.log)[ \t%a]*;", "error_log %1;")
            contents = string.gsub(contents, "lua_code_cache[ \t]+%a+;", "lua_code_cache on;")
        end
        
        -- copy app_entry.conf to tmp/
        local apps = ngx.apps
        local includes = {}
        for name, path in pairs(apps) do
            local entryPath = string.format("%s/conf/app_entry.conf", path)
            local varEntryPath = string.format("%s/app_%s_entry.conf", TMP_DIR, name)
            if io.exists(entryPath) then
                local entry = io.readfile(entryPath)
                entry = string.gsub(entry, "_GBC_CORE_ROOT_", ROOT_DIR)
                entry = string.gsub(entry, "_APP_ROOT_", path)
                io.writefile(varEntryPath, entry)
                includes[#includes + 1] = string.format("        include %s;", varEntryPath)
            end
        end
        includes = "\n" .. table.concat(includes, "\n")
        contents = string.gsub(contents, "\n[ \t]*#[ \t]*_INCLUDE_APPS_ENTRY_", includes)
        contents = string.gsub(contents, "_NGX_INDEX_", ngx.name)
        io.writefile(VAR_NGINX_CONF_PATH..ngx.name, contents)
    end
end

_updateRedisConfig = function()
    local config = _checkVarConfig()
    
    local contents = io.readfile(REDIS_CONF_PATH)
    contents = string.gsub(contents, "_GBC_CORE_ROOT_", ROOT_DIR)
    
    local socket = _getValue(config, "server.redis.socket")
    if socket then
        if string.sub(socket, 1, 5) == "unix:" then
            socket = string.sub(socket, 6)
        end
        contents = string.gsub(contents, "[# \t]*unixsocket[ \t]+[^\n]+", string.format("unixsocket %s", socket))
    else
        contents = string.gsub(contents, "[# \t]*unixsocket[ \t]+", "# unixsocket")
    end
    
    local host = _getValue(config, "server.redis.host", "127.0.0.1")
    local port = _getValue(config, "server.redis.port", 6379)
    if host and port then
        contents = string.gsub(contents, "[# \t]*bind[ \t]+[%d\\.]+", "bind " .. host)
        contents = string.gsub(contents, "[# \t]*port[ \t]+%d+", "port " .. port)
    else
        contents = string.gsub(contents, "[# \t]*bind[ \t]+[%d\\.]+", "# bind 127.0.0.1")
        contents = string.gsub(contents, "[# \t]*port[ \t]+%d+", "port 0")
    end
    
    io.writefile(VAR_REDIS_CONF_PATH, contents)
end

_updateBackupConfig = function()
    local contents = io.readfile(BACKUP_CONF_PATH)
    contents = string.gsub(contents, "_GBC_CORE_ROOT_", ROOT_DIR)
    io.writefile(VAR_BACKUP_CONF_PATH, contents)
end

local _SUPERVISOR_WORKER_PROG_TMPL = [[
[program:worker-_APP_NAME_]
command=_GBC_CORE_ROOT_/bin/openresty/luajit/bin/lua _GBC_CORE_ROOT_/bin/start_worker.lua _GBC_CORE_ROOT_ _APP_ROOT_PATH_
process_name=%%(process_num)02d
numprocs=_NUM_PROCESS_
redirect_stderr=true
stdout_logfile=_GBC_CORE_ROOT_/logs/worker-_APP_NAME_.log
]]

local _NGINX_PROG_TMPL = [[
[program:nginx-_INDEX]
command=_GBC_CORE_ROOT_/bin/openresty/nginx/sbin/nginx -c _GBC_CORE_ROOT_/tmp/nginx.conf_INDEX
;stopsignal=QUIT
redirect_stderr=true
stdout_logfile=_GBC_CORE_ROOT_/logs/nginx-error_INDEX.log ;
]]

_updateSupervisordConfig = function()
    local config = _checkVarConfig()
    local beanport = _getValue(config, "server.beanstalkd.port")
    
    local contents = io.readfile(SUPERVISORD_CONF_PATH)
    contents = string.gsub(contents, "_GBC_CORE_ROOT_", ROOT_DIR)
    contents = string.gsub(contents, "_BEANSTALKD_PORT_", beanport)
    
    local nginxs = config.server.nginx
    local ngxs = {}
    for index, ngx in ipairs(nginxs) do
        local prog = string.gsub(_NGINX_PROG_TMPL, "_GBC_CORE_ROOT_", ROOT_DIR)
        local prog = string.gsub(prog, "_INDEX", ngx.name)
        table.insert(ngxs, prog)
    end
    contents = string.gsub(contents, ";_NGINX_", table.concat(ngxs, "\n"))
    
    local workers = {}
    for index, ngx in ipairs(nginxs) do
        local appkeys = _checkAppKeys(ngx.name)
        local appConfigs = Factory.makeAppConfigs(appkeys, config, package.path)
        local apps = ngx.apps
        for name, path in pairs(apps) do
            local prog = string.gsub(_SUPERVISOR_WORKER_PROG_TMPL, "_GBC_CORE_ROOT_", ROOT_DIR)
            prog = string.gsub(prog, "_APP_ROOT_PATH_", path)
            prog = string.gsub(prog, "_APP_NAME_", name)
            
            -- get numOfJobWorkers
            local appConfig = appConfigs[path]
            prog = string.gsub(prog, "_NUM_PROCESS_", appConfig.app.numOfJobWorkers)
            
            workers[#workers + 1] = prog
        end
    end
    contents = string.gsub(contents, ";_WORKERS_", table.concat(workers, "\n"))
    
    io.writefile(VAR_SUPERVISORD_CONF_PATH, contents)
end
