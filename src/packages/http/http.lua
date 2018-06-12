local http = require "resty.http"
local M = {}
local json = cc.import("#json")
local json_encode = json.encode
local json_decode = json.decode

function M.Post(host, port, path, data)
    local httpc = http.new()
    httpc:set_timeout(500)
    local uri = string.format("http://%s:%d/%s", host, port, path)
    local res, err = httpc:request_uri(uri, {
        method = "POST",
        body = json_encode(data),
        headers = {
            ["Content-Type"] = "application/json",
        },
    })
    
    if not res then
        cc.printf("failed to request: ", err)
        return
    end
    return json_decode(res.body)
end

return M

