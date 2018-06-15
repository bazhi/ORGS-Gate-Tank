using Google.Protobuf;
using System.Collections.Generic;
namespace Pb{
    public enum PBDefine{
		Unknow,
		Pack,
		Error,
		CreateRole,
		Role
    }

	public static class PBRegister
	{
		public static void Register(ref Dictionary<PBDefine, MessageParser>dict)
		{
			dict.Add(PBDefine.Pack, Pack.Parser);
			dict.Add(PBDefine.Error, Error.Parser);
			dict.Add(PBDefine.CreateRole, CreateRole.Parser);
			dict.Add(PBDefine.Role, Role.Parser);
		}
	}
}