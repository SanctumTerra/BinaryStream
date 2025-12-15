const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Uint64 = struct {
    pub fn write(stream: *BinaryStream, value: u64, endianess: ?Endianess) !void {
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(value),
            .Big => std.mem.toBytes(@byteSwap(value)),
        };
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u64 {
        const bytes = stream.read(8);
        if (bytes.len < 8) {
            return error.NotEnoughBytes;
        }
        const value = std.mem.bytesToValue(u64, bytes[0..8]);
        return switch (endianess orelse .Big) {
            .Little => value,
            .Big => @byteSwap(value),
        };
    }
};

test "UInt64 read/write" {
    std.debug.print("Running test: UInt64 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u64 = 42;
    try Uint64.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint64.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
