[返回主页](/index.html)
#protobuf定义
```protobuf
syntax = "proto3";
package pb;

/*
	Pack==1
	Error==2
	Operation==3
*/
message Pack{
	int32 type = 1;
	bytes content = 2; //actions的参数
	int32 msgid = 3;
}

message Error{
	enum EType{
		None = 0;
		UserLoggedIn = 1; //用户已经登陆
	}
	EType code = 1; //错误码
}

message Operation{
	bool result = 1;
	int32 type = 2;
}

message Vector{
	float x = 1;
	float y = 2;
	float z = 3;
}

message ShootSync{
	int32 id = 1;
	Vector turretRotation = 2;
}

message TankSync{
	int32 id = 1;
	Vector position = 2;
	Vector rotation = 3;
	Vector turretRotation = 4;
}```
