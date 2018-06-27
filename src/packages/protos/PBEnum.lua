local _M = {
	Error={
		EType={
			None = 0,
			UserLoggedIn = 1,
			NoSetNickname = 2,
			NoneConfigID = 3,
			Config = 4,
			ID = 5,
			Unfinished = 6,
			NoAccept = 7,
			NoParam = 8,
			UnexpectedError = 10,
			ConfigError = 11,
			NoneRole = 1001,
			NoneProp = 1002,
			NoneEquipment = 1003,
			NoneBox = 1004,
			NoneMission = 1011,
			OperationNotPermit = 2001,
		},
	},
}
return table.readonly(_M)