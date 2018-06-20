[返回主页](/index.html)
#protobuf定义
```protobuf
syntax = "proto3";
package pb;

message Pack{
	int32 type = 1;
	bytes content = 2; //actions的参数
}

message Error{
	enum EType{
		None = 0;
		UserLoggedIn = 1; //用户已经登陆
		NoSetNickname = 2; //没有设置好用户名
		UnexpectedError = 10; //不期望的错误
		ConfigError = 11; //配置表错误
		NoneRole = 1001; //还没有创建角色
		NoneProp = 1002; //道具不存在
		NoneEquipment = 1003; //装备不存在

		OperationNotPermit = 2001; //操作不允许
	}
	EType code = 1; //错误码
}

//Server Command
/*
ID 名称说明
id: 道具ID，存储的ID
cid: 配置表ID
oid：配置表中的originalId
*/
//创建角色命令
message CreateRole{
	string nickname = 1; //昵称
}

//升级武器品质命令
message UpgradeQuality
{
	int32 id = 1; //武器id
	int32 prop_id = 2; //道具id
}

//升级星级
message UpgradeStar
{
	int32 id = 1; //武器id
	int32 prop_id = 2; //道具id
}

//升级等级
message UpgradeLevel
{
	int32 id = 1; //武器id
	int32 prop_id = 2; //道具id
}

//分解物品
message Decompose
{
	int32 id = 1; //分解的道具id
}

//数据
message Role{
	int32 id = 1;
    int32 pid = 2;
    int32 cid = 3;
    string nickname = 4;
    int32 level = 5;
    int32 gold = 6;
    int32 diamond = 7;
    int32 loginTime = 8;
    int32 createTime = 9;
}

message Prop{
	int32 id = 1;
	int32 rid = 2;
	int32 cid = 3;
	int32 count = 4;
}

message Props{
	repeated Prop values = 1;
}

message Equipment{
	int32 id = 1;
	int32 rid = 2;
	int32 cid = 3;
	int32 star = 4;
	int32 oid = 5;
}

message Equipments{
	repeated Equipment values = 1;
}```