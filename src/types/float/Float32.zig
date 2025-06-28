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
    pub fn read(stream: *BinaryStream, endianess: ?Endianess) f32 {
        const bytes = stream.read(4);
        if (bytes.len < 4) {
            std.log.err("Cannot read float32: not enough bytes", .{});
            return 0;
        }

        var bits: u32 = undefined;
        switch (endianess orelse .Big) {
            .Little => {
                bits = @as(u32, @intCast(bytes[0])) |
                    (@as(u32, @intCast(bytes[1])) << 8) |
                    (@as(u32, @intCast(bytes[2])) << 16) |
                    (@as(u32, @intCast(bytes[3])) << 24);
            },
            .Big => {
                bits = (@as(u32, @intCast(bytes[0])) << 24) |
                    (@as(u32, @intCast(bytes[1])) << 16) |
                    (@as(u32, @intCast(bytes[2])) << 8) |
                    @as(u32, @intCast(bytes[3]));
            },
        }

        return @bitCast(bits);
    }

    /// Writes a 32-bit floating-point value to the stream.
    pub fn write(stream: *BinaryStream, value: f32, endianess: ?Endianess) void {
        const bits: u32 = @bitCast(value);
        var bytes: [4]u8 = undefined;

        switch (endianess orelse .Big) {
            .Little => {
                bytes[0] = @intCast(bits & 0xFF);
                bytes[1] = @intCast((bits >> 8) & 0xFF);
                bytes[2] = @intCast((bits >> 16) & 0xFF);
                bytes[3] = @intCast((bits >> 24) & 0xFF);
            },
            .Big => {
                bytes[0] = @intCast((bits >> 24) & 0xFF);
                bytes[1] = @intCast((bits >> 16) & 0xFF);
                bytes[2] = @intCast((bits >> 8) & 0xFF);
                bytes[3] = @intCast(bits & 0xFF);
            },
        }

        stream.write(&bytes);
    }
};

test "Float32 read/write" {
    std.debug.print("Running test: Float32 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: f32 = 3.14159;
    Float32.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = Float32.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
