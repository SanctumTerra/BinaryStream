const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const Uint32 = @import("../unsigned/UInt32.zig").Uint32;

/// **String32**
///
/// A string with a 32-bit unsigned integer length prefix.
/// Maximum string length is 4,294,967,295 bytes.
///
/// The length is written as a Uint32 value, followed by the string data.
pub const String32 = struct {
    /// Reads a string prefixed with a 32-bit length.
    /// First reads the length as a Uint32, then reads that many bytes.
    pub fn read(stream: *BinaryStream, endianess: ?Endianess) ![]const u8 {
        const length = try Uint32.read(stream, endianess);
        return stream.read(length);
    }

    /// Writes a string prefixed with a 32-bit length.
    /// First writes the length as a Uint32, then writes the string data.
    pub fn write(stream: *BinaryStream, value: []const u8, endianess: ?Endianess) !void {
        try Uint32.write(stream, @intCast(value.len), endianess);
        try stream.write(value);
    }
};

test "String32 read/write" {
    std.debug.print("Running test: String32 read/write\n", .{});
    var buffer: [100]u8 = [_]u8{0} ** 100;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a string
    const test_value = "Hello, world! This is a longer string for testing.";
    try String32.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the string
    const read_value = try String32.read(&stream, .Big);

    // Compare the strings
    try std.testing.expectEqual(test_value.len, read_value.len);
    for (0..test_value.len) |i| {
        try std.testing.expectEqual(test_value[i], read_value[i]);
    }
}
