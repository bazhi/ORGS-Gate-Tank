using Google.Protobuf;
using System.Collections.Generic;
namespace Pb{
    public enum PBDefine{
        Unknow,
        Pack = 1,
        Error = 2,
        Operation = 3
    }

    public static class PBRegister
    {
        public static void Register(ref Dictionary<PBDefine, MessageParser>dict)
        {
            dict.Add(PBDefine.Pack, Pack.Parser);
            dict.Add(PBDefine.Error, Error.Parser);
            dict.Add(PBDefine.Operation, Operation.Parser);
        }
    }
}