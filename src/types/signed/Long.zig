const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const Int64 = @import("Int64.zig").Int64;

pub const Long = struct {
    pub fn write(stream: *BinaryStream, value: i64, endianess: ?Endianess) void {
        Int64.write(stream, value, endianess);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) i64 {
        return Int64.read(stream, endianess);
    }
};

test "Long read/write" {
    std.debug.print("Running test: Long read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i64 = 42;
    Long.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = Long.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
