const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int24 = struct {
    pub fn write(stream: *BinaryStream, value: i32, endianess: ?Endianess) void {
        switch (endianess orelse .Big) {
            .Little => {
                stream.write(
                    &[_]u8{
                        @intCast(value & 0xFF),
                        @intCast((value >> 8) & 0xFF),
                        @intCast((value >> 16) & 0xFF),
                    },
                );
            },
            .Big => {
                stream.write(
                    &[_]u8{
                        @intCast((value >> 16) & 0xFF),
                        @intCast((value >> 8) & 0xFF),
                        @intCast(value & 0xFF),
                    },
                );
            },
        }
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) i32 {
        const value = stream.read(3);
        if (value.len < 3) {
            std.log.err("Cannot read int24: not enough bytes", .{});
            return 0;
        }

        var result: i32 = 0;
        switch (endianess orelse .Big) {
            .Little => {
                // Little endian: [byte0, byte1, byte2, 0]
                result = @as(i32, @intCast(value[0])) |
                    (@as(i32, @intCast(value[1])) << 8) |
                    (@as(i32, @intCast(value[2])) << 16);

                // Sign extension if the highest bit is set
                if ((value[2] & 0x80) != 0) {
                    result |= @as(i32, -16777216); // 0xFF000000 as i32 (sign extended)
                }
            },
            .Big => {
                // Big endian: [0, byte0, byte1, byte2]
                result = (@as(i32, @intCast(value[0])) << 16) |
                    (@as(i32, @intCast(value[1])) << 8) |
                    @as(i32, @intCast(value[2]));

                // Sign extension if the highest bit is set
                if ((value[0] & 0x80) != 0) {
                    result |= @as(i32, -16777216); // 0xFF000000 as i32 (sign extended)
                }
            },
        }

        return result;
    }
};

test "Int24 read/write" {
    std.debug.print("Running test: Int24 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i32 = 42;
    Int24.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = Int24.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
