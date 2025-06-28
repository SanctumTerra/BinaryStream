const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const Uint64 = @import("../../types/unsigned/UInt64.zig").Uint64;

pub const ULong = struct {
    pub fn write(stream: *BinaryStream, value: u64, endianess: ?Endianess) void {
        Uint64.write(stream, value, endianess);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) u64 {
        return Uint64.read(stream, endianess);
    }
};

test "ULong read/write" {
    std.debug.print("Running test: ULong read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u64 = 42;
    ULong.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = ULong.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
