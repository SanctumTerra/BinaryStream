const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;
const VarInt = @import("VarInt.zig").VarInt;

/// **ZigZag**
///
/// An encoding for signed integers that maps them to unsigned integers
/// in a way that preserves small absolute values. This makes variable-length
/// encoding more efficient for negative numbers.
///
/// For example:
///   0 → 0, -1 → 1, 1 → 2, -2 → 3, 2 → 4, ...
pub const ZigZag = struct {
    /// Reads a ZigZag-encoded signed 32-bit integer.
    /// First reads a VarInt, then decodes it from ZigZag encoding.
    pub fn read(self: *BinaryStream) i32 {
        const value = VarInt.read(self, null);
        return @as(i32, @intCast(value >> 1)) ^ (-@as(i32, @intCast(value & 1)));
    }

    /// Writes a signed 32-bit integer using ZigZag encoding.
    /// First encodes the signed value to ZigZag, then writes it as a VarInt.
    pub fn write(self: *BinaryStream, value: i32) void {
        const encoded = @as(u32, @intCast((value << 1) ^ (value >> 31)));
        VarInt.write(self, encoded, null);
    }
};

test "ZigZag read/write" {
    std.debug.print("Running test: ZigZag read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing positive and negative values
    const test_values = [_]i32{ 0, 1, -1, 2, -2, 127, -127, 128, -128, 1000, -1000 };

    for (test_values) |test_value| {
        // Clear buffer and reset stream for each test
        for (0..buffer.len) |i| {
            buffer[i] = 0;
        }
        stream.offset = 0;

        // Write the value
        ZigZag.write(&stream, test_value);

        // Reset offset to read from the beginning
        stream.offset = 0;

        // Read the value
        const read_value = ZigZag.read(&stream);
        try std.testing.expectEqual(test_value, read_value);
    }
}
