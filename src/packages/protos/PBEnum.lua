local _M = {
	Error={
		EType={
			None = 0,
			UserLoggedIn = 1,
			NoSetNickname = 2,
			NoneRole = 1001,
		},
	},
}
return table.readonly(_M)