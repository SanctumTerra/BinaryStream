const std = @import("std");
pub const BinaryStream = @import("stream/BinaryStream.zig").BinaryStream;
pub const Endianess = @import("enums/Endianess.zig").Endianess;
pub const Uint8 = @import("types/unsigned/UInt8.zig").Uint8;
pub const Uint16 = @import("types/unsigned/UInt16.zig").Uint16;
pub const Uint24 = @import("types/unsigned/UInt24.zig").Uint24;
pub const Uint32 = @import("types/unsigned/UInt32.zig").Uint32;
pub const Uint64 = @import("types/unsigned/UInt64.zig").Uint64;
pub const ULong = @import("types/unsigned/ULong.zig").ULong;
pub const UShort = @import("types/unsigned/UShort.zig").UShort;
pub const Bool = @import("types/unsigned/Bool.zig").Bool;
pub const Byte = @import("types/signed/Byte.zig").Byte;
pub const Int8 = @import("types/signed/Int8.zig").Int8;
pub const Int16 = @import("types/signed/Int16.zig").Int16;
pub const Int24 = @import("types/signed/Int24.zig").Int24;
pub const Int32 = @import("types/signed/Int32.zig").Int32;
pub const Int64 = @import("types/signed/Int64.zig").Int64;
pub const Long = @import("types/signed/Long.zig").Long;
pub const Short = @import("types/signed/Short.zig").Short;
pub const VarInt = @import("types/varint/VarInt.zig").VarInt;
pub const VarLong = @import("types/varint/VarLong.zig").VarLong;
pub const ZigZag = @import("types/varint/ZigZag.zig").ZigZag;
pub const ZigZong = @import("types/varint/ZigZong.zig").ZigZong;
pub const String16 = @import("types/string/String16.zig").String16;
pub const String32 = @import("types/string/String32.zig").String32;
pub const VarString = @import("types/string/VarString.zig").VarString;
pub const Uuid = @import("types/string/Uuid.zig").Uuid;
pub const Float32 = @import("types/float/Float32.zig").Float32;
pub const Float64 = @import("types/float/Float64.zig").Float64;

test {
    // UInt tests
    std.testing.refAllDecls(@import("types/unsigned/UInt8.zig"));
    std.testing.refAllDecls(@import("types/unsigned/UInt16.zig"));
    std.testing.refAllDecls(@import("types/unsigned/UInt24.zig"));
    std.testing.refAllDecls(@import("types/unsigned/UInt32.zig"));
    std.testing.refAllDecls(@import("types/unsigned/UInt64.zig"));
    std.testing.refAllDecls(@import("types/unsigned/ULong.zig"));
    std.testing.refAllDecls(@import("types/unsigned/UShort.zig"));
    std.testing.refAllDecls(@import("types/unsigned/Bool.zig"));
    // Signed tests
    std.testing.refAllDecls(@import("types/signed/Byte.zig"));
    std.testing.refAllDecls(@import("types/signed/Int8.zig"));
    std.testing.refAllDecls(@import("types/signed/Int16.zig"));
    std.testing.refAllDecls(@import("types/signed/Int24.zig"));
    std.testing.refAllDecls(@import("types/signed/Int32.zig"));
    std.testing.refAllDecls(@import("types/signed/Int64.zig"));
    std.testing.refAllDecls(@import("types/signed/Long.zig"));
    std.testing.refAllDecls(@import("types/signed/Short.zig"));
    std.testing.refAllDecls(@import("types/varint/VarInt.zig"));
    std.testing.refAllDecls(@import("types/varint/VarLong.zig"));
    std.testing.refAllDecls(@import("types/varint/ZigZag.zig"));
    std.testing.refAllDecls(@import("types/varint/ZigZong.zig"));
    // String tests
    std.testing.refAllDecls(@import("types/string/String16.zig"));
    std.testing.refAllDecls(@import("types/string/String32.zig"));
    std.testing.refAllDecls(@import("types/string/VarString.zig"));
    std.testing.refAllDecls(@import("types/string/Uuid.zig"));
    // Float tests
    std.testing.refAllDecls(@import("types/float/Float32.zig"));
    std.testing.refAllDecls(@import("types/float/Float64.zig"));
}
