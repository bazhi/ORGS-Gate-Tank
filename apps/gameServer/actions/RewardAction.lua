
local gbc = cc.import("#gbc")
local RewardAction = cc.class("RewardAction", gbc.ActionBase)
-- local dbConfig = cc.import("#dbConfig")
-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig

RewardAction.ACCEPTED_REQUEST_TYPE = "websocket"

return RewardAction
