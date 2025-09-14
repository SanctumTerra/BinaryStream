const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Uint8 = @import("../../types/unsigned/UInt8.zig").Uint8;

pub const Bool = struct {
    pub fn write(stream: *BinaryStream, value: bool) !void {
        try Uint8.write(stream, if (value) 1 else 0);
    }

    pub fn read(stream: *BinaryStream) !bool {
        return try Uint8.read(stream) == 1;
    }
};

test "Bool read/write" {
    std.debug.print("Running test: Bool read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: bool = true;
    try Bool.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Bool.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
