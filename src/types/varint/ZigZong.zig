const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const VarLong = @import("VarLong.zig").VarLong;

/// **ZigZong**
///
/// An encoding for signed 64-bit integers that maps them to unsigned integers
/// in a way that preserves small absolute values. This makes variable-length
/// encoding more efficient for negative numbers.
///
/// For example:
///   0 → 0, -1 → 1, 1 → 2, -2 → 3, 2 → 4, ...
///
/// Works like ZigZag but for 64-bit integers (i64).
pub const ZigZong = struct {
    /// Reads a ZigZong-encoded signed 64-bit integer.
    /// First reads a VarLong, then decodes it from ZigZag encoding.
    pub fn read(self: *BinaryStream) !i64 {
        const value = try VarLong.read(self);
        return @as(i64, @bitCast(value >> 1)) ^ (-@as(i64, @intCast(value & 1)));
    }

    /// Writes a signed 64-bit integer using ZigZag encoding.
    /// First encodes the signed value to ZigZag, then writes it as a VarLong.
    pub fn write(self: *BinaryStream, value: i64) !void {
        const encoded = @as(u64, @bitCast((value << 1) ^ (value >> 63)));
        try VarLong.write(self, encoded);
    }
};

test "ZigZong read/write" {
    std.debug.print("Running test: ZigZong read/write\n", .{});
    var buffer: [20]u8 = [_]u8{0} ** 20;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing positive and negative values
    const test_values = [_]i64{ 0, 1, -1, 2, -2, 127, -127, 128, -128, 1000, -1000, 1000000000, -1000000000, 9223372036854775807, -9223372036854775807 };

    for (test_values) |test_value| {
        // Clear buffer and reset stream for each test
        for (0..buffer.len) |i| {
            buffer[i] = 0;
        }
        stream.offset = 0;

        // Write the value
        try ZigZong.write(&stream, test_value);

        // Reset offset to read from the beginning
        stream.offset = 0;

        // Read the value
        const read_value = try ZigZong.read(&stream);
        try std.testing.expectEqual(test_value, read_value);
    }
}
