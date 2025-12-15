const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

/// **Float32**
///
/// A 32-bit (4 byte) IEEE 754 floating-point number.
///
/// Supports both big-endian and little-endian byte ordering.
pub const Float32 = struct {
    /// Reads a 32-bit floating-point value from the stream.
    pub fn read(stream: *BinaryStream, endianess: ?Endianess) error{NotEnoughBytes}!f32 {
        const bytes = stream.read(4);
        if (bytes.len < 4) {
            return error.NotEnoughBytes;
        }
        const bits = std.mem.bytesToValue(u32, bytes[0..4]);
        const swapped = switch (endianess orelse .Big) {
            .Little => bits,
            .Big => @byteSwap(bits),
        };
        return @bitCast(swapped);
    }

    /// Writes a 32-bit floating-point value to the stream.
    pub fn write(stream: *BinaryStream, value: f32, endianess: ?Endianess) !void {
        const bits: u32 = @bitCast(value);
        const bytes = switch (endianess orelse .Big) {
            .Little => std.mem.toBytes(bits),
            .Big => std.mem.toBytes(@byteSwap(bits)),
        };
        try stream.write(&bytes);
    }
};

test "Float32 read/write" {
    std.debug.print("Running test: Float32 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: f32 = 3.14159;
    try Float32.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Float32.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
