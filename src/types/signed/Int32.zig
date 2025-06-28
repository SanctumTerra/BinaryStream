const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Int32 = struct {
    pub fn write(stream: *BinaryStream, value: i32, endianess: ?Endianess) void {
        switch (endianess orelse .Big) {
            .Little => {
                stream.write(&[_]u8{
                    @intCast(value & 0xFF),
                    @intCast((value >> 8) & 0xFF),
                    @intCast((value >> 16) & 0xFF),
                    @intCast((value >> 24) & 0xFF),
                });
            },
            .Big => {
                stream.write(&[_]u8{
                    @intCast((value >> 24) & 0xFF),
                    @intCast((value >> 16) & 0xFF),
                    @intCast((value >> 8) & 0xFF),
                    @intCast(value & 0xFF),
                });
            },
        }
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) i32 {
        const value = stream.read(4);
        if (value.len < 4) {
            std.log.err("Cannot read int32: not enough bytes", .{});
            return 0;
        }

        switch (endianess orelse .Big) {
            .Little => {
                return @as(i32, @intCast(value[0])) | (@as(i32, @intCast(value[1])) << 8) | (@as(i32, @intCast(value[2])) << 16) | (@as(i32, @intCast(value[3])) << 24);
            },
            .Big => {
                return (@as(i32, @intCast(value[0])) << 24) | (@as(i32, @intCast(value[1])) << 16) | (@as(i32, @intCast(value[2])) << 8) | @as(i32, @intCast(value[3]));
            },
        }
    }
};

test "Int32 read/write" {
    std.debug.print("Running test: Int32 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: i32 = 42;
    Int32.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = Int32.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
