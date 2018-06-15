[返回主页](/index.html)
#protobuf定义
```protobuf
syntax = "proto3";
package pb;

message Pack{
	//string action = 1;
	int32 type = 1;
	bytes content = 2; //actions的参数
}

message Error{
	enum EType{
		None = 0;
		UserLoggedIn = 1; //用户已经登陆
		NoSetNickname = 2; //没有设置好用户名
		NoneRole = 1001; //还没有创建角色

	}
	EType code = 1; //错误码
}

//Server Command

message CreateRole{
	string nickname = 1; //昵称
}


//数据
message Role{
	int32 id = 1;
    int32 pid = 2;
    string nickname = 3;
    int32 level = 4;
    int32 gold = 5;
    int32 diamond = 6;
    int32 loginTime = 7;
    int32 createTime = 8;
}```
