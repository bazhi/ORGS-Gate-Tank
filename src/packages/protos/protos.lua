local pb = require "protobuf"
pb.register_file(cc.pb_file)
pb.CmdToPB = cc.import(".CmdToPB")
pb.PBToCmd = cc.import(".PBToCmd")
pb.PBEnum = cc.import(".PBEnum")
return pb
