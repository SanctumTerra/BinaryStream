const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int16 = struct {
    pub fn write(stream: *BinaryStream, value: i16, endianess: ?Endianess) !void {
        const unsigned: u16 = @bitCast(value);
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(unsigned),
            .Big => std.mem.toBytes(@byteSwap(unsigned)),
        };
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !i16 {
        const bytes = stream.read(2);
        if (bytes.len < 2) {
            std.log.err("Cannot read int16: not enough bytes", .{});
            return 0;
        }
        const unsigned = std.mem.bytesToValue(u16, bytes[0..2]);
        const swapped = switch (endianess orelse .Big) {
            .Little => unsigned,
            .Big => @byteSwap(unsigned),
        };
        return @bitCast(swapped);
    }
};

test "Int16 read/write" {
    std.debug.print("Running test: Int16 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i16 = 42;
    try Int16.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Int16.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
