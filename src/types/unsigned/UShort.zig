const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const Uint16 = @import("../../types/unsigned/UInt16.zig").Uint16;

pub const UShort = struct {
    pub fn write(stream: *BinaryStream, value: u16, endianess: ?Endianess) !void {
        try Uint16.write(stream, value, endianess);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u16 {
        return try Uint16.read(stream, endianess);
    }
};

test "UShort read/write" {
    std.debug.print("Running test: UShort read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u16 = 42;
    try UShort.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try UShort.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
