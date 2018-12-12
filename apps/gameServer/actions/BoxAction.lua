
local gbc = cc.import("#gbc")
local BoxAction = cc.class("BoxAction", gbc.ActionBase)
-- local dbConfig = cc.import("#dbConfig")
-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig

BoxAction.ACCEPTED_REQUEST_TYPE = "websocket"

return BoxAction

