local _M = {
	Error={
		EType={
			None = 0,
			UserLoggedIn = 1,
			NoSetNickname = 2,
			UnexpectedError = 10,
			ConfigError = 11,
			NoneRole = 1001,
			NoneProp = 1002,
			NoneEquipment = 1003,
			OperationNotPermit = 2001,
		},
	},
}
return table.readonly(_M)