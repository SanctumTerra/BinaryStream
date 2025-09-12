const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Int8 = @import("../../types/signed/Int8.zig").Int8;

pub const Byte = struct {
    pub fn write(stream: *BinaryStream, value: i8) !void {
        try Int8.write(stream, value);
    }

    pub fn read(stream: *BinaryStream) !i8 {
        return try Int8.read(stream);
    }
};

test "Byte read/write" {
    std.debug.print("Running test: Byte read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i8 = 42;
    try Byte.write(&stream, test_value);
    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Byte.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
