const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Uint16 = struct {
    pub fn write(stream: *BinaryStream, value: u16, endianess: ?Endianess) !void {
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(value),
            .Big => std.mem.toBytes(@byteSwap(value)),
        };
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u16 {
        const bytes = stream.read(2);
        if (bytes.len < 2) {
            return error.NotEnoughBytes;
        }
        const value = std.mem.bytesToValue(u16, bytes[0..2]);
        return switch (endianess orelse .Big) {
            .Little => value,
            .Big => @byteSwap(value),
        };
    }
};

test "Uint16 read/write" {
    std.debug.print("Running test: Uint16 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u16 = 42;
    try Uint16.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint16.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
