[返回主页](/index.html)
#protobuf定义
```protobuf
syntax = "proto3";
package pb;

message Pack{
	int32 type = 1;
	bytes content = 2; //actions的参数
	int32 msgid = 3;
}

message Error{
	enum EType{
		None = 0;
		UserLoggedIn = 1; //用户已经登陆
		NoSetNickname = 2; //没有设置好用户名
		NoneConfigID = 3; //缺少Config ID
		NoneID = 4; //缺少参数ID
		NoneConfig = 5; //缺少配置文件
		Unfinished = 6; //未完成
		NoAccept = 7; //没达到条件，不接受
		NoParam = 8; //缺少参数
		UnexpectedError = 10; //不期望的错误
		ConfigError = 11; //配置表错误
		OutOfDate = 12; //已经过期
		LessGold = 13; //金币不够
		LessDiamond = 14;//钻石不够
		LessTimes = 15;//超出次数
		NoneRole = 1001; //还没有创建角色
		NoneProp = 1002; //道具不存在
		NoneEquipment = 1003; //装备不存在
		NoneBox = 1004; //箱子不存在
		NoneGold = 1005; //金币不足
		NonoDiamond = 1006; //钻石不足

		NoneMission = 1011; //找不到任务

		OperationNotPermit = 2001; //操作不允许
	}
	EType code = 1; //错误码
}

message Operation{
	int32 result = 1; //-1:表示有错误吗，0:表示操作失败，1:表示操作成功
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

//升级星级
message UpgradeStar{
	int32 id = 1; //武器id
	repeated int32 prop_ids = 2 [packed=true]; //道具id
}

//升级星级
message UnlockEquipment{
	int32 cid = 1; //武器id
	int32 prop_id = 2; //道具id
}

//升级等级
message UpgradeLevel{
	int32 id = 1; //武器id
	int32 prop_id = 2; //道具id
}

//分解物品
message Decompose{
	int32 id = 1; //分解的道具id
}

//进入章节
message EnterChapter{
	int32 cid = 1; //进入章节
}

message EnterSection{
	int32 cid = 1; //进入Section
}

message FinishSection{
	int32 id = 1; //关卡等级
	int32 star = 2; //关卡星级
}

message FinishMission{
	int32 id = 1; //mission id
}

//打开箱子
message OpenBox{
	int32 id = 1;
}
//收取箱子里的物品
message GainBox{
	int32 id = 1;
}

message Delete{
	int32 id = 1; //需要删除的类型
	int32 type = 2; // 需要删除的ID
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
    int32 exp = 10;
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
	int32 exp = 6;
}

message Equipments{
	repeated Equipment values = 1;
}

message Chapter{
	int32 id = 1;
	int32 rid = 2;
	int32 cid = 3;
	int32 status = 4;
	bytes record1 = 5;
	bytes record2 = 6;
	bytes record3 = 7;
}

message Chapters{
	repeated Chapter values = 1;
}

message Section{
	int32 id = 1;
	int32 rid = 2;
	int32 cid = 3;
	int32 chapter_cid = 4;
	int32 star = 5;
	int32 tryTimes = 6;
	int32 finishTimes = 7;
	int32 enterTime = 8;
}

message SectionResult{
	int32 id = 1;
	int32 star = 2;
	int32 exp = 3;
}

message Sections{
	repeated Section values = 1;
}

message Mission{
	int32 id = 1;
    int32 rid = 2;
    int32 cid = 3;
  	int32 progress = 4;
}

message Missions{
	repeated Mission values = 1;
}

message Box{
	int32 id = 1;
   	int32 rid = 2;
   	int32 cid = 3;
   	int32 unlockTime = 4; //解锁时间，0为未解锁，否则为解锁结束时间
}

message Boxes{
	repeated Box values = 1;
}

message Reward{
	int32 cid = 1;
	int32 count = 2;
}

message Rewards{
	repeated Reward values = 1;
	int32 gold = 2; //金币
	int32 diamond = 3; //钻石
}

message SigninRecord{
	int32 times = 1;
	repeated int32 record = 2 [packed=true]; //已经签到天
}

message SigninGet{
	int32 day = 1; //获取第几天的奖励
}

message ShopGet{
	int32 id = 1; //购买商店物品
}

message ShopRecord{
	repeated int32 id = 1 [packed=true]; //已经签到天
	repeated int32 times = 2 [packed=true]; //已经签到天
}

message CompositeItem{
	int32 id = 1;
	int32 timeEnd = 2;
}

//武器或者道具
message ItemData{
	int32 id = 1; //id
	int32 count = 2; //道具数量或者武器的子弹装载数量
}

//角色数据
message PlayerData{
	int32 health = 1;
	int32 stamina = 2;
	repeated ItemData props = 3;
	repeated ItemData weapons = 4;
}

//建筑数据
message BuildData{
	int32 level = 1;
	int32 health = 2;
	int32 upgradeTime = 3;
	int32 repairTime = 4;
	repeated CompositeItem composites = 5;
	repeated ItemData props = 6; //仓库中才使用
	repeated ItemData weapons = 7; //仓库中才使用
}
//日历数据
message CalendarData{
	int32 minutes = 1;
}
//id对应的数据
message BuildItem{
	int32 id = 1;
	bytes contents = 2;
}
//地图记录
message MapRecord{
	repeated BuildItem items = 2;
	int32 time = 3;
}

message MapRecordSave{
	int32 id = 1;
	int32 seq = 2;
	bytes record = 3;
}```
