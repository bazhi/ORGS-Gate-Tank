using Google.Protobuf;
using System.Collections.Generic;
namespace Pb{
    public enum PBDefine{
		Unknow,
		Pack
    }

	public static class PBRegister
	{
		public static void Register(ref Dictionary<PBDefine, MessageParser>dict)
		{
			dict.Add(PBDefine.Pack, Pack.Parser);
		}
	}
}