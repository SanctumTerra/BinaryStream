const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

/// **Float64**
///
/// A 64-bit (8 byte) IEEE 754 floating-point number.
///
/// Supports both big-endian and little-endian byte ordering.
pub const Float64 = struct {
    /// Reads a 64-bit floating-point value from the stream.
    pub fn read(stream: *BinaryStream, endianess: ?Endianess) error{NotEnoughBytes}!f64 {
        const bytes = stream.read(8);
        if (bytes.len < 8) {
            return error.NotEnoughBytes;
        }
        const bits = std.mem.bytesToValue(u64, bytes[0..8]);
        const swapped = switch (endianess orelse .Big) {
            .Little => bits,
            .Big => @byteSwap(bits),
        };
        return @bitCast(swapped);
    }

    /// Writes a 64-bit floating-point value to the stream.
    pub fn write(stream: *BinaryStream, value: f64, endianess: ?Endianess) !void {
        const bits: u64 = @bitCast(value);
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(bits),
            .Big => std.mem.toBytes(@byteSwap(bits)),
        };
        try stream.write(&bytes);
    }
};

test "Float64 read/write" {
    std.debug.print("Running test: Float64 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: f64 = 3.14159265358979;
    try Float64.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Float64.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
