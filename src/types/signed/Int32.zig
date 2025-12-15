const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int32 = struct {
    pub fn write(stream: *BinaryStream, value: i32, endianess: ?Endianess) !void {
        const unsigned: u32 = @bitCast(value);
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(unsigned),
            .Big => std.mem.toBytes(@byteSwap(unsigned)),
        };
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) error{NotEnoughBytes}!i32 {
        const bytes = stream.read(4);
        if (bytes.len < 4) {
            return error.NotEnoughBytes;
        }
        const unsigned = std.mem.bytesToValue(u32, bytes[0..4]);
        const swapped = switch (endianess orelse .Big) {
            .Little => unsigned,
            .Big => @byteSwap(unsigned),
        };
        return @bitCast(swapped);
    }
};

test "Int32 read/write" {
    std.debug.print("Running test: Int32 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i32 = 42;
    try Int32.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Int32.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
