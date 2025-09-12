const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int16 = struct {
    pub fn write(stream: *BinaryStream, value: i16, endianess: ?Endianess) !void {
        switch (endianess orelse .Big) {
            .Little => {
                try stream.write(&[_]u8{ @intCast(value & 0xFF), @intCast((value >> 8) & 0xFF) });
            },
            .Big => {
                try stream.write(&[_]u8{ @intCast((value >> 8) & 0xFF), @intCast(value & 0xFF) });
            },
        }
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !i16 {
        const value = stream.read(2);
        if (value.len < 2) {
            std.log.err("Cannot read int16: not enough bytes", .{});
            return 0;
        }

        switch (endianess orelse .Big) {
            .Little => {
                return @as(i16, @intCast(value[0])) | (@as(i16, @intCast(value[1])) << 8);
            },
            .Big => {
                return (@as(i16, @intCast(value[0])) << 8) | @as(i16, @intCast(value[1]));
            },
        }
    }
};

test "Int16 read/write" {
    std.debug.print("Running test: Int16 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i16 = 42;
    try Int16.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Int16.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
