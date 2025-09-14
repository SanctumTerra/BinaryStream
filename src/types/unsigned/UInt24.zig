const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Uint24 = struct {
    pub fn write(stream: *BinaryStream, value: u24, endianess: ?Endianess) !void {
        var bytes: [3]u8 = undefined;
        switch (endianess orelse .Big) {
            .Little => {
                bytes[0] = @intCast(value & 0xFF);
                bytes[1] = @intCast((value >> 8) & 0xFF);
                bytes[2] = @intCast((value >> 16) & 0xFF);
            },
            .Big => {
                bytes[0] = @intCast((value >> 16) & 0xFF);
                bytes[1] = @intCast((value >> 8) & 0xFF);
                bytes[2] = @intCast(value & 0xFF);
            },
        }
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u24 {
        const bytes = stream.read(3);
        if (bytes.len < 3) {
            return error.NotEnoughBytes;
        }
        return switch (endianess orelse .Big) {
            .Little => @as(u24, @intCast(bytes[0])) | (@as(u24, @intCast(bytes[1])) << 8) | (@as(u24, @intCast(bytes[2])) << 16),
            .Big => (@as(u24, @intCast(bytes[0])) << 16) | (@as(u24, @intCast(bytes[1])) << 8) | @as(u24, @intCast(bytes[2])),
        };
    }
};

test "Uint24 read/write" {
    std.debug.print("Running test: Uint24 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u24 = 42;
    try Uint24.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint24.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
