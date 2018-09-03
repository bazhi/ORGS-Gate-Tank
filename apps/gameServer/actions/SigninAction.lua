
local gbc = cc.import("#gbc")
local SigninAction = cc.class("SigninAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig

SigninAction.ACCEPTED_REQUEST_TYPE = "websocket"

function SigninAction:getAction(args, redis)
    
end

function SigninAction:login(args, redis)
    
end

return SigninAction
