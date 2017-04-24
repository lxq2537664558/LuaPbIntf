local M = {}

local pb = require("luapbintf")

-- test.proto imports common.proto
pb.import_proto_file("test.proto")

function M.test_rpc()
    assert(pb.get_rpc_input_name("test.Test", "Foo") == "test.TestMsg")
    assert(pb.get_rpc_output_name("test.Test", "Foo") == "test.CommonMsg")
end  -- test_rpc()

function M.test_encode_decode()
    local msg = { uid = 12345 }
    local s = pb.encode("test.TestMsg", msg)
    local msg2 = pb.decode("test.TestMsg", s)
    assert(msg2.uid == 12345)
end  -- test_encode_decode()

function M.test_repeated()
    local msg = { names = {"n1", "n2", "n3"} }
    local s = pb.encode("test.TestMsg", msg)
    local msg2 = pb.decode("test.TestMsg", s)
    assert(#msg2.names == 3)
    assert("n3" == msg2.names[3])  -- Maybe reordered.
end  -- test_repeated()

function M.test_default_value()
    local msg2 = assert(pb.decode("test.TestMsg", ""))
    assert(nil == msg2.common_msg)
    assert(0 == msg2.cmd)
    assert(#msg2.names == 0)
end

function M.test_type_convertion()
    local msg = { uid = "12345" }
    local s = pb.encode("test.TestMsg", msg)
    assert(pb.decode("test.TestMsg", s).uid == 12345)
end  -- test_type_convertion()

function M.test_string_enum()
    local msg = { cmd = "CMD_TYPE_CHECK" }
    local s = pb.encode("test.TestMsg", msg)
    assert(pb.decode("test.TestMsg", s).cmd == 2)
end  -- test_string_enum()

function M.test_s1234_enum()
    local msg = { cmd = "1234" }
    local s = pb.encode("test.TestMsg", msg)
    assert(pb.decode("test.TestMsg", s).cmd == 1234)
end  -- test_string_enum()

function M.test_many_fields()
    local msg = {
        uid = 12345,
        param = 9876,
        name = "Jin Qing",
        names = {"n1", "n2", "n3"},
        cmd = 10,
        common_msg = {},
    }

    local s = pb.encode("test.TestMsg", msg)
    local msg2 = pb.decode("test.TestMsg", s)
    assert(msg2.name == "Jin Qing")
    assert(#msg2.names == 3)
    local n3 = msg2.names[3]
    -- Maybe reordered.
    assert(n3 == "n1" or n3 == "n2" or n3 == "n3")
    assert(10 == msg2.cmd)
    assert(msg2.common_msg)
end  -- test_encode_decode()

--local enum_value = pb.getEnumValue("lm.Cmd", "CMD_TYPE_USER")
--print(enum_value)

function M.test_all()
    M.test_rpc()
    M.test_encode_decode()
    M.test_repeated()
    M.test_default_value()
    M.test_type_convertion()
    M.test_string_enum()
    M.test_s1234_enum()
    M.test_many_fields()
    print("Test all OK!")
end  -- test_all

M.test_all()
return M
