const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Uint32 = struct {
    pub fn write(stream: *BinaryStream, value: u32, endianess: ?Endianess) !void {
        var bytes: [4]u8 = undefined;
        switch (endianess orelse .Big) {
            .Little => {
                bytes[0] = @intCast(value & 0xFF);
                bytes[1] = @intCast((value >> 8) & 0xFF);
                bytes[2] = @intCast((value >> 16) & 0xFF);
                bytes[3] = @intCast((value >> 24) & 0xFF);
            },
            .Big => {
                bytes[0] = @intCast((value >> 24) & 0xFF);
                bytes[1] = @intCast((value >> 16) & 0xFF);
                bytes[2] = @intCast((value >> 8) & 0xFF);
                bytes[3] = @intCast(value & 0xFF);
            },
        }
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u32 {
        const bytes = stream.read(4);
        if (bytes.len < 4) {
            std.log.err("Cannot read uint32: not enough bytes", .{});
            return 0;
        }
        return switch (endianess orelse .Big) {
            .Little => @as(u32, @intCast(bytes[0])) | (@as(u32, @intCast(bytes[1])) << 8) | (@as(u32, @intCast(bytes[2])) << 16) | (@as(u32, @intCast(bytes[3])) << 24),
            .Big => (@as(u32, @intCast(bytes[0])) << 24) | (@as(u32, @intCast(bytes[1])) << 16) | (@as(u32, @intCast(bytes[2])) << 8) | @as(u32, @intCast(bytes[3])),
        };
    }
};

test "UInt32 read/write" {
    std.debug.print("Running test: UInt32 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u32 = 42;
    try Uint32.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint32.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
