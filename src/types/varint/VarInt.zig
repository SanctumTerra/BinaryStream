const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;

/// **VarInt**
///
/// A variable-length encoded 32-bit integer.
/// Uses 1-5 bytes depending on value magnitude.
///
/// Valid range: 0 to 4,294,967,295 (unsigned)
pub const VarInt = struct {
    /// Reads a variable-length encoded integer from the stream.
    pub fn read(stream: *BinaryStream) !u32 {
        const payload = stream.payload;
        const written = stream.written;
        var offset = stream.offset;
        var value: u32 = 0;
        var shift: u5 = 0;

        while (shift < 35) {
            if (offset >= written) return error.NotEnoughBytes;
            const byte = payload[offset];
            offset += 1;
            value |= @as(u32, byte & 0x7F) << shift;
            if (byte & 0x80 == 0) {
                stream.offset = offset;
                return value;
            }
            shift += 7;
        }

        return error.VarIntTooBig;
    }

    /// Writes a variable-length encoded integer to the stream.
    pub fn write(stream: *BinaryStream, value: u32) !void {
        var buf: [5]u8 = undefined;
        var v = value;
        var len: usize = 0;

        while (true) {
            if ((v & ~@as(u32, 0x7F)) == 0) {
                buf[len] = @truncate(v);
                len += 1;
                break;
            }
            buf[len] = @as(u8, @truncate(v & 0x7F)) | 0x80;
            v >>= 7;
            len += 1;
        }

        try stream.write(buf[0..len]);
    }
};

test "VarInt read/write" {
    std.debug.print("Running test: VarInt read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u32 = 51727646;
    try VarInt.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try VarInt.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
