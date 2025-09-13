const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const Int16 = @import("Int16.zig").Int16;

pub const Short = struct {
    pub fn write(stream: *BinaryStream, value: i16, endianess: ?Endianess) !void {
        try Int16.write(stream, value, endianess);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !i16 {
        return try Int16.read(stream, endianess);
    }
};

test "Short read/write" {
    std.debug.print("Running test: Short read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i16 = 42;
    try Short.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Short.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
