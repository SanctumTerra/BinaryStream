const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

/// **VarLong**
///
/// A 64-bit integer encoded in a variable-length format.
/// Uses 1-10 bytes depending on the value, with smaller values using fewer bytes.
/// Each byte uses 7 bits for data and 1 bit as continuation flag.
///
/// Valid range: 0 to 18,446,744,073,709,551,615 (unsigned)
pub const VarLong = struct {
    /// Reads a variable-length encoded long integer from the stream.
    /// Reads one byte at a time until a byte without the continuation bit is found.
    /// The endianess parameter is ignored for VarLong as it uses a special encoding.
    pub fn read(self: *BinaryStream) u64 {
        var value: u64 = 0;
        var size: u4 = 0;

        while (true) {
            const bytes = self.read(1);
            if (bytes.len < 1) {
                std.log.err("Cannot read VarLong: not enough bytes", .{});
                return 0;
            }

            const current_byte = bytes[0];
            const shift_amount: u6 = switch (size) {
                0 => 0,
                1 => 7,
                2 => 14,
                3 => 21,
                4 => 28,
                5 => 35,
                6 => 42,
                7 => 49,
                8 => 56,
                9 => 63,
                else => {
                    std.log.err("VarLong is too big", .{});
                    return 0;
                },
            };

            value |= @as(u64, current_byte & 0x7F) << shift_amount;
            size +%= 1;

            if (size > 10) {
                std.log.err("VarLong is too big", .{});
                return 0;
            }

            if (current_byte & 0x80 != 0x80) break;
        }

        return value;
    }

    /// Writes a variable-length encoded long integer to the stream.
    /// Each byte uses 7 bits of data and 1 bit as a continuation flag.
    /// The endianess parameter is ignored for VarLong as it uses a special encoding.
    pub fn write(self: *BinaryStream, mut_value: u64) void {
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

test "VarLong read/write" {
    std.debug.print("Running test: VarLong read/write\n", .{});
    var buffer: [20]u8 = [_]u8{0} ** 20;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u64 = 12345678901234;
    VarLong.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = VarLong.read(&stream);
    try std.testing.expectEqual(test_value, read_value);
}
