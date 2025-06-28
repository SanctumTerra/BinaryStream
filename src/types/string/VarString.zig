const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const VarInt = @import("../varint/VarInt.zig").VarInt;

/// **VarString**
///
/// A string with a VarInt length prefix.
/// Uses variable-length encoding for the size prefix, making it efficient
/// for storing strings of various lengths.
///
/// The length is written as a VarInt value, followed by the string data.
pub const VarString = struct {
    /// Reads a string prefixed with a VarInt length.
    /// First reads the length as a VarInt, then reads that many bytes.
    pub fn read(stream: *BinaryStream) []const u8 {
        const length = VarInt.read(stream, .Big);
        return stream.read(length);
    }

    /// Writes a string prefixed with a VarInt length.
    /// First writes the length as a VarInt, then writes the string data.
    pub fn write(stream: *BinaryStream, value: []const u8) void {
        VarInt.write(stream, @intCast(value.len), .Big);
        stream.write(value);
    }
};

test "VarString read/write" {
    std.debug.print("Running test: VarString read/write\n", .{});
    var buffer: [100]u8 = [_]u8{0} ** 100;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a string
    const test_value = "Hello, world! This is a VarString.";
    VarString.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the string
    const read_value = VarString.read(&stream);

    // Compare the strings
    try std.testing.expectEqual(test_value.len, read_value.len);
    for (0..test_value.len) |i| {
        try std.testing.expectEqual(test_value[i], read_value[i]);
    }
}
