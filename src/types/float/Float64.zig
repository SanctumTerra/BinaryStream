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
    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !f64 {
        const bytes = stream.read(8);
        if (bytes.len < 8) {
            std.log.err("Cannot read float64: not enough bytes", .{});
            return 0;
        }

        var bits: u64 = undefined;
        switch (endianess orelse .Big) {
            .Little => {
                bits = @as(u64, @intCast(bytes[0])) |
                    (@as(u64, @intCast(bytes[1])) << 8) |
                    (@as(u64, @intCast(bytes[2])) << 16) |
                    (@as(u64, @intCast(bytes[3])) << 24) |
                    (@as(u64, @intCast(bytes[4])) << 32) |
                    (@as(u64, @intCast(bytes[5])) << 40) |
                    (@as(u64, @intCast(bytes[6])) << 48) |
                    (@as(u64, @intCast(bytes[7])) << 56);
            },
            .Big => {
                bits = (@as(u64, @intCast(bytes[0])) << 56) |
                    (@as(u64, @intCast(bytes[1])) << 48) |
                    (@as(u64, @intCast(bytes[2])) << 40) |
                    (@as(u64, @intCast(bytes[3])) << 32) |
                    (@as(u64, @intCast(bytes[4])) << 24) |
                    (@as(u64, @intCast(bytes[5])) << 16) |
                    (@as(u64, @intCast(bytes[6])) << 8) |
                    @as(u64, @intCast(bytes[7]));
            },
        }

        return @bitCast(bits);
    }

    /// Writes a 64-bit floating-point value to the stream.
    pub fn write(stream: *BinaryStream, value: f64, endianess: ?Endianess) !void {
        const bits: u64 = @bitCast(value);
        var bytes: [8]u8 = undefined;

        switch (endianess orelse .Big) {
            .Little => {
                bytes[0] = @intCast(bits & 0xFF);
                bytes[1] = @intCast((bits >> 8) & 0xFF);
                bytes[2] = @intCast((bits >> 16) & 0xFF);
                bytes[3] = @intCast((bits >> 24) & 0xFF);
                bytes[4] = @intCast((bits >> 32) & 0xFF);
                bytes[5] = @intCast((bits >> 40) & 0xFF);
                bytes[6] = @intCast((bits >> 48) & 0xFF);
                bytes[7] = @intCast((bits >> 56) & 0xFF);
            },
            .Big => {
                bytes[0] = @intCast((bits >> 56) & 0xFF);
                bytes[1] = @intCast((bits >> 48) & 0xFF);
                bytes[2] = @intCast((bits >> 40) & 0xFF);
                bytes[3] = @intCast((bits >> 32) & 0xFF);
                bytes[4] = @intCast((bits >> 24) & 0xFF);
                bytes[5] = @intCast((bits >> 16) & 0xFF);
                bytes[6] = @intCast((bits >> 8) & 0xFF);
                bytes[7] = @intCast(bits & 0xFF);
            },
        }

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
