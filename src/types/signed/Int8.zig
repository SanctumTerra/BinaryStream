const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;

pub const Int8 = struct {
    pub fn write(stream: *BinaryStream, value: i8) void {
        // Convert to unsigned for bit representation, preserving the bit pattern
        stream.write(&[_]u8{@bitCast(@as(u8, @bitCast(value)))});
    }

    pub fn read(stream: *BinaryStream) i8 {
        const value = stream.read(1);
        if (value.len < 1) {
            std.log.err("Cannot read int8: not enough bytes", .{});
            return 0;
        }
        return @bitCast(value[0]);
    }
};

test "Int8 read/write" {
    std.debug.print("Running test: Int8 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i8 = 42;
    Int8.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = Int8.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
