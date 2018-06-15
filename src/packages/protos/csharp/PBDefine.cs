using Google.Protobuf;
using System.Collections.Generic;
namespace Pb{
    public enum PBDefine{
		Unknow,
		Pack,
		Error,
		CreateRole,
		Role,
		Prop,
		Props,
		Equipment,
		Equipments
    }

	public static class PBRegister
	{
		public static void Register(ref Dictionary<PBDefine, MessageParser>dict)
		{
			dict.Add(PBDefine.Pack, Pack.Parser);
			dict.Add(PBDefine.Error, Error.Parser);
			dict.Add(PBDefine.CreateRole, CreateRole.Parser);
			dict.Add(PBDefine.Role, Role.Parser);
			dict.Add(PBDefine.Prop, Prop.Parser);
			dict.Add(PBDefine.Props, Props.Parser);
			dict.Add(PBDefine.Equipment, Equipment.Parser);
			dict.Add(PBDefine.Equipments, Equipments.Parser);
		}
	}
}