const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;

/// **VarLong**
///
/// A variable-length encoded 64-bit integer.
/// Uses 1-10 bytes depending on value magnitude.
///
/// Valid range: 0 to 18,446,744,073,709,551,615 (unsigned)
pub const VarLong = struct {
    /// Reads a variable-length encoded long integer from the stream.
    pub fn read(stream: *BinaryStream) !u64 {
        const buffer = stream.payload.items;
        var offset = stream.offset;
        var value: u64 = 0;
        var shift: u6 = 0;
        var i: u4 = 0;

        while (i < 10) : (i += 1) {
            if (offset >= buffer.len) return error.NotEnoughBytes;
            const byte = buffer[offset];
            offset += 1;
            value |= @as(u64, byte & 0x7F) << shift;
            if (byte & 0x80 == 0) {
                stream.offset = offset;
                return value;
            }
            shift +%= 7;
        }

        return error.VarLongTooBig;
    }

    /// Writes a variable-length encoded long integer to the stream.
    pub fn write(stream: *BinaryStream, value: u64) !void {
        var buf: [10]u8 = undefined;
        var v = value;
        var len: usize = 0;

        while (true) {
            if ((v & ~@as(u64, 0x7F)) == 0) {
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

test "VarLong read/write" {
    std.debug.print("Running test: VarLong read/write\n", .{});
    var buffer: [20]u8 = [_]u8{0} ** 20;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u64 = 12345678901234;
    try VarLong.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try VarLong.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
