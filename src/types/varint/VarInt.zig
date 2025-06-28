const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

/// **VarInt**
///
/// A 32-bit integer encoded in little-endian byte order.
/// Takes 4 bytes regardless of value.
///
/// Valid range: 0 to 4,294,967,295 (unsigned)
pub const VarInt = struct {
    /// Reads a variable-length encoded integer from the stream.
    /// Reads one byte at a time until a byte without the continuation bit is found.
    /// The endianess parameter is ignored for VarInt as it uses a special encoding.
    pub fn read(self: *BinaryStream, _: ?Endianess) u32 {
        var value: u32 = 0;
        var size: u3 = 0;

        while (true) {
            const bytes = self.read(1);
            if (bytes.len < 1) {
                std.log.err("Cannot read VarInt: not enough bytes", .{});
                return 0;
            }

            const current_byte = bytes[0];
            const shift_amount: u5 = switch (size) {
                0 => 0,
                1 => 7,
                2 => 14,
                3 => 21,
                4 => 28,
                else => {
                    std.log.err("VarInt is too big", .{});
                    return 0;
                },
            };

            value |= @as(u32, current_byte & 0x7F) << shift_amount;
            size +%= 1;

            if (size > 5) {
                std.log.err("VarInt is too big", .{});
                return 0;
            }

            if (current_byte & 0x80 != 0x80) break;
        }

        return value;
    }

    /// Writes a variable-length encoded integer to the stream.
    /// Each byte uses 7 bits of data and 1 bit as a continuation flag.
    /// The endianess parameter is ignored for VarInt as it uses a special encoding.
    pub fn write(self: *BinaryStream, mut_value: u32, _: ?Endianess) void {
        var value = mut_value;

        while (true) {
            var byte: u8 = @intCast(value & 0x7F);
            value >>= 7;

            if (value != 0) {
                byte |= 0x80;
            }

            self.write(&[_]u8{byte});

            if (value == 0) {
                break;
            }
        }
    }
};

test "VarInt read/write" {
    std.debug.print("Running test: VarInt read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u32 = 51727646;
    VarInt.write(&stream, test_value, null);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = VarInt.read(&stream, null);
    try std.testing.expectEqual(test_value, read_value);
}
