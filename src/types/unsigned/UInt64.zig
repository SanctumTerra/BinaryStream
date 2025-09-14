const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

pub const Uint64 = struct {
    pub fn write(stream: *BinaryStream, value: u64, endianess: ?Endianess) !void {
        var bytes: [8]u8 = undefined;
        switch (endianess orelse .Big) {
            .Little => {
                bytes[0] = @intCast(value & 0xFF);
                bytes[1] = @intCast((value >> 8) & 0xFF);
                bytes[2] = @intCast((value >> 16) & 0xFF);
                bytes[3] = @intCast((value >> 24) & 0xFF);
                bytes[4] = @intCast((value >> 32) & 0xFF);
                bytes[5] = @intCast((value >> 40) & 0xFF);
                bytes[6] = @intCast((value >> 48) & 0xFF);
                bytes[7] = @intCast((value >> 56) & 0xFF);
            },
            .Big => {
                bytes[0] = @intCast((value >> 56) & 0xFF);
                bytes[1] = @intCast((value >> 48) & 0xFF);
                bytes[2] = @intCast((value >> 40) & 0xFF);
                bytes[3] = @intCast((value >> 32) & 0xFF);
                bytes[4] = @intCast((value >> 24) & 0xFF);
                bytes[5] = @intCast((value >> 16) & 0xFF);
                bytes[6] = @intCast((value >> 8) & 0xFF);
                bytes[7] = @intCast(value & 0xFF);
            },
        }
        try stream.write(&bytes);
    }

    pub fn read(stream: *BinaryStream, endianess: ?Endianess) !u64 {
        const bytes = stream.read(8);
        if (bytes.len < 8) {
            return error.NotEnoughBytes;
        }
        return switch (endianess orelse .Big) {
            .Little => @as(u64, @intCast(bytes[0])) | (@as(u64, @intCast(bytes[1])) << 8) | (@as(u64, @intCast(bytes[2])) << 16) | (@as(u64, @intCast(bytes[3])) << 24) | (@as(u64, @intCast(bytes[4])) << 32) | (@as(u64, @intCast(bytes[5])) << 40) | (@as(u64, @intCast(bytes[6])) << 48) | (@as(u64, @intCast(bytes[7])) << 56),
            .Big => (@as(u64, @intCast(bytes[0])) << 56) | (@as(u64, @intCast(bytes[1])) << 48) | (@as(u64, @intCast(bytes[2])) << 40) | (@as(u64, @intCast(bytes[3])) << 32) | (@as(u64, @intCast(bytes[4])) << 24) | (@as(u64, @intCast(bytes[5])) << 16) | (@as(u64, @intCast(bytes[6])) << 8) | @as(u64, @intCast(bytes[7])),
        };
    }
};

test "UInt64 read/write" {
    std.debug.print("Running test: UInt64 read/write\n", .{});
    var buffer: [10]u8 = [_]u8{0} ** 10;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    // Test writing a value
    const test_value: u64 = 42;
    try Uint64.write(&stream, test_value, .Big);

    // Reset offset to read from the beginning
    stream.offset = 0;

    // Test reading the value
    const read_value = try Uint64.read(&stream, .Big);
    try std.testing.expectEqual(test_value, read_value);
}
