const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Uint16 = struct {
    pub fn write(stream: *BinaryStream, value: u16, endianess: ?Endianess) !void {
        var bytes: [2]u8 = undefined;
        switch (endianess orelse .Big) {
            .Little => {
                bytes[0] = @intCast(value & 0xFF);
                bytes[1] = @intCast((value >> 8) & 0xFF);
            },
            .Big => {
                bytes[0] = @intCast((value >> 8) & 0xFF);
                bytes[1] = @intCast(value & 0xFF);
            },
        }
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u16 {
        const bytes = stream.read(2);
        if (bytes.len < 2) {
            return error.NotEnoughBytes;
        }
        return switch (endianess orelse .Big) {
            .Little => @as(u16, @intCast(bytes[0])) | (@as(u16, @intCast(bytes[1])) << 8),
            .Big => (@as(u16, @intCast(bytes[0])) << 8) | @as(u16, @intCast(bytes[1])),
        };
    }
};

test "Uint16 read/write" {
    std.debug.print("Running test: Uint16 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u16 = 42;
    try Uint16.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint16.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
