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

test "binary stream basic read/write" {
    const allocator = std.testing.allocator;
    var stream = BinaryStream.init(allocator, null, null);
    defer stream.deinit();

    const endian = Endianess.Big;

    // Write values
    // Unsigned integers
    stream.writeUint8(123);
    stream.writeUint16(12345, endian);
    stream.writeUint24(123456, endian);
    stream.writeUint32(1234567890, endian);
    stream.writeUint64(12345678901234, endian);
    stream.writeULong(9876543210, endian);
    stream.writeUShort(9876, endian);
    stream.writeBool(true);
    stream.writeBool(false);

    // Signed integers
    stream.writeByte(-123);
    stream.writeInt8(-123);
    stream.writeInt16(-12345, endian);
    stream.writeInt24(-123456, endian);
    stream.writeInt32(-1234567890, endian);
    stream.writeInt64(-12345678901234, endian);
    stream.writeLong(-9876543210, endian);
    stream.writeShort(-9876, endian);

    // Floats
    stream.writeFloat32(3.14159, endian);
    stream.writeFloat64(2.71828182846, endian);

    // Reset offset for reading
    stream.offset = 0;

    // Read and verify values
    // Unsigned integers
    try std.testing.expectEqual(@as(u8, 123), stream.readUint8());
    try std.testing.expectEqual(@as(u16, 12345), stream.readUint16(endian));
    try std.testing.expectEqual(@as(u24, 123456), stream.readUint24(endian));
    try std.testing.expectEqual(@as(u32, 1234567890), stream.readUint32(endian));
    try std.testing.expectEqual(@as(u64, 12345678901234), stream.readUint64(endian));
    try std.testing.expectEqual(@as(u64, 9876543210), stream.readULong(endian));
    try std.testing.expectEqual(@as(u16, 9876), stream.readUShort(endian));
    try std.testing.expectEqual(true, stream.readBool());
    try std.testing.expectEqual(false, stream.readBool());

    // Signed integers
    try std.testing.expectEqual(@as(i8, -123), stream.readByte());
    try std.testing.expectEqual(@as(i8, -123), stream.readInt8());
    try std.testing.expectEqual(@as(i16, -12345), stream.readInt16(endian));
    try std.testing.expectEqual(@as(i32, -123456), stream.readInt24(endian));
    try std.testing.expectEqual(@as(i32, -1234567890), stream.readInt32(endian));
    try std.testing.expectEqual(@as(i64, -12345678901234), stream.readInt64(endian));
    try std.testing.expectEqual(@as(i64, -9876543210), stream.readLong(endian));
    try std.testing.expectEqual(@as(i16, -9876), stream.readShort(endian));

    // Floats
    const epsilon32: f32 = 0.00001;
    const epsilon64: f64 = 0.00000000001;

    try std.testing.expectApproxEqAbs(@as(f32, 3.14159), stream.readFloat32(endian), epsilon32);
    try std.testing.expectApproxEqAbs(@as(f64, 2.71828182846), stream.readFloat64(endian), epsilon64);
}
