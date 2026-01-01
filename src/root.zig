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
    try stream.writeUint8(123);
    try stream.writeUint16(12345, endian);
    try stream.writeUint24(123456, endian);
    try stream.writeUint32(1234567890, endian);
    try stream.writeUint64(12345678901234, endian);
    try stream.writeULong(9876543210, endian);
    try stream.writeUShort(9876, endian);
    try stream.writeBool(true);
    try stream.writeBool(false);

    // Signed integers
    try stream.writeByte(-123);
    try stream.writeInt8(-123);
    try stream.writeInt16(-12345, endian);
    try stream.writeInt24(-123456, endian);
    try stream.writeInt32(-1234567890, endian);
    try stream.writeInt64(-12345678901234, endian);
    try stream.writeLong(-9876543210, endian);
    try stream.writeShort(-9876, endian);

    // Floats
    try stream.writeFloat32(3.14159, endian);
    try stream.writeFloat64(2.71828182846, endian);

    // Reset offset for reading
    stream.offset = 0;

    // Read and verify values
    // Unsigned integers
    try std.testing.expectEqual(@as(u8, 123), try stream.readUint8());
    try std.testing.expectEqual(@as(u16, 12345), try stream.readUint16(endian));
    try std.testing.expectEqual(@as(u24, 123456), try stream.readUint24(endian));
    try std.testing.expectEqual(@as(u32, 1234567890), try stream.readUint32(endian));
    try std.testing.expectEqual(@as(u64, 12345678901234), try stream.readUint64(endian));
    try std.testing.expectEqual(@as(u64, 9876543210), try stream.readULong(endian));
    try std.testing.expectEqual(@as(u16, 9876), try stream.readUShort(endian));
    try std.testing.expectEqual(true, try stream.readBool());
    try std.testing.expectEqual(false, try stream.readBool());

    // Signed integers
    try std.testing.expectEqual(@as(i8, -123), try stream.readByte());
    try std.testing.expectEqual(@as(i8, -123), try stream.readInt8());
    try std.testing.expectEqual(@as(i16, -12345), try stream.readInt16(endian));
    try std.testing.expectEqual(@as(i32, -123456), try stream.readInt24(endian));
    try std.testing.expectEqual(@as(i32, -1234567890), try stream.readInt32(endian));
    try std.testing.expectEqual(@as(i64, -12345678901234), try stream.readInt64(endian));
    try std.testing.expectEqual(@as(i64, -9876543210), try stream.readLong(endian));
    try std.testing.expectEqual(@as(i16, -9876), try stream.readShort(endian));

    // Floats
    const epsilon32: f32 = 0.00001;
    const epsilon64: f64 = 0.00000000001;

    try std.testing.expectApproxEqAbs(@as(f32, 3.14159), try stream.readFloat32(endian), epsilon32);
    try std.testing.expectApproxEqAbs(@as(f64, 2.71828182846), try stream.readFloat64(endian), epsilon64);
}

test "Packet" {
    var stream = BinaryStream.init(std.testing.allocator, null, null);
    defer stream.deinit();

    // Write a packet ID as VarInt
    const packet_id: u32 = 0x1234;
    try VarInt.write(&stream, packet_id);
    // Write some data (e.g., a string)
    const test_string = "Hello, World!";
    try VarString.write(&stream, test_string);
    // Write some long string
    const long_string = "Earth is the third planet from the Sun and the only astronomical object known to harbor life. This is enabled by Earth being an ocean world, the only one in the Solar System sustaining liquid surface water. Almost all of Earth's water is contained in its global ocean, covering 70.8% of Earth's crust. The remaining 29.2% of Earth's crust is land, most of which is located in the form of continental landmasses within Earth's land hemisphere. Most of Earth's land is at least somewhat humid and covered by vegetation, while large ice sheets at Earth's polar deserts retain more water than Earth's groundwater, lakes, rivers, and atmospheric water combined. Earth's crust consists of slowly moving tectonic plates, which interact to produce mountain ranges, volcanoes, and earthquakes. Earth has a liquid outer core that generates a magnetosphere capable of deflecting most of the destructive solar winds and cosmic radiation.";
    try VarString.write(&stream, long_string);

    for (0..10) |i| {
        _ = i;
        try VarString.write(&stream, long_string);
    }

    // Reset offset for reading
    stream.offset = 0;

    // Read and verify packet ID
    const read_packet_id = try VarInt.read(&stream);
    const read_string = try VarString.read(&stream);
    const read_long_string = try VarString.read(&stream);

    try std.testing.expectEqual(packet_id, read_packet_id);
    try std.testing.expectEqualStrings(test_string, read_string);
    try std.testing.expectEqualStrings(long_string, read_long_string);

    for (0..10) |i| {
        _ = i;
        const str = try VarString.read(&stream);
        try std.testing.expectEqualStrings(long_string, str);
    }

    std.debug.print("-- Packet read/write test passed --\n", .{});
    std.debug.print("Packet ID: {d}\n", .{read_packet_id});
    std.debug.print("Test String: {s}\n", .{read_string});
    std.debug.print("Long String: {s}\n", .{read_long_string});
    std.debug.print("Total bytes in stream: {d}\n", .{stream.written});
    std.debug.print("-------------------------------\n", .{});
}
