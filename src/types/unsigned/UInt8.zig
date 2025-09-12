const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;

pub const Uint8 = struct {
    pub fn write(stream: *BinaryStream, value: u8) !void {
        try stream.write(&[_]u8{value});
    }

    pub fn read(stream: *BinaryStream) !u8 {
        const value = stream.read(1);
        if (value.len < 1) {
            std.log.err("Cannot read uint8: not enough bytes", .{});
            return 0;
        }
        return value[0];
    }
};

test "UInt8 read/write" {
    std.debug.print("Running test: UInt8 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u8 = 42;
    try Uint8.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint8.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
