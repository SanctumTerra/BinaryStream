const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int64 = struct {
    pub fn write(stream: *BinaryStream, value: i64, endianess: ?Endianess) !void {
        switch (endianess orelse .Big) {
            .Little => {
                try stream.write(
                    &[_]u8{
                        @intCast(value & 0xFF),
                        @intCast((value >> 8) & 0xFF),
                        @intCast((value >> 16) & 0xFF),
                        @intCast((value >> 24) & 0xFF),
                        @intCast((value >> 32) & 0xFF),
                        @intCast((value >> 40) & 0xFF),
                        @intCast((value >> 48) & 0xFF),
                        @intCast((value >> 56) & 0xFF),
                    },
                );
            },
            .Big => {
                try stream.write(
                    &[_]u8{
                        @intCast((value >> 56) & 0xFF),
                        @intCast((value >> 48) & 0xFF),
                        @intCast((value >> 40) & 0xFF),
                        @intCast((value >> 32) & 0xFF),
                        @intCast((value >> 24) & 0xFF),
                        @intCast((value >> 16) & 0xFF),
                        @intCast((value >> 8) & 0xFF),
                        @intCast(value & 0xFF),
                    },
                );
            },
        }
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) error{NotEnoughBytes}!i64 {
        const value = stream.read(8);
        if (value.len < 8) {
            return error.NotEnoughBytes;
        }
        switch (endianess orelse .Big) {
            .Little => {
                return @as(i64, @intCast(value[0])) | (@as(i64, @intCast(value[1])) << 8) | (@as(i64, @intCast(value[2])) << 16) | (@as(i64, @intCast(value[3])) << 24) | (@as(i64, @intCast(value[4])) << 32) | (@as(i64, @intCast(value[5])) << 40) | (@as(i64, @intCast(value[6])) << 48) | (@as(i64, @intCast(value[7])) << 56);
            },
            .Big => {
                return (@as(i64, @intCast(value[0])) << 56) | (@as(i64, @intCast(value[1])) << 48) | (@as(i64, @intCast(value[2])) << 40) | (@as(i64, @intCast(value[3])) << 32) | (@as(i64, @intCast(value[4])) << 24) | (@as(i64, @intCast(value[5])) << 16) | (@as(i64, @intCast(value[6])) << 8) | @as(i64, @intCast(value[7]));
            },
        }
    }
};

test "Int64 read/write" {
    std.debug.print("Running test: Int64 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i64 = 42;
    try Int64.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Int64.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
