const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int64 = struct {
    pub fn write(stream: *BinaryStream, value: i64, endianess: ?Endianess) !void {
        const unsigned: u64 = @bitCast(value);
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(unsigned),
            .Big => std.mem.toBytes(@byteSwap(unsigned)),
        };
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) error{NotEnoughBytes}!i64 {
        const bytes = stream.read(8);
        if (bytes.len < 8) {
            return error.NotEnoughBytes;
        }
        const unsigned = std.mem.bytesToValue(u64, bytes[0..8]);
        const swapped = switch (endianess orelse .Big) {
            .Little => unsigned,
            .Big => @byteSwap(unsigned),
        };
        return @bitCast(swapped);
    }
};

test "Int64 read/write" {
    std.debug.print("Running test: Int64 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i64 = 42;
    try Int64.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Int64.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
