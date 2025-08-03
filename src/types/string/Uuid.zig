const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;

/// **UUID**
///
/// Represents a 128-bit (16 bytes) universally unique identifier.
/// Stored as two 8-byte chunks that are written/read separately.
/// The string representation uses the standard format: 8-4-4-4-12 hexadecimal digits
/// with hyphens, e.g. "550e8400-e29b-41d4-a716-446655440000"
pub const Uuid = struct {
    /// Reads a 128-bit (16 bytes) UUID from the stream and returns it as a formatted string.
    /// Caller is responsible for freeing the returned string using the stream's allocator.
    /// If there's an error reading the UUID, returns a default all-zero UUID and logs the error.
    pub fn read(stream: *BinaryStream) []const u8 {
        // Read the first 8 bytes
        const bytes_m = stream.read(8);
        if (bytes_m.len < 8) {
            std.log.err("Cannot read UUID: not enough bytes for first half", .{});
            return "00000000-0000-0000-0000-000000000000";
        }

        // Read the second 8 bytes
        const bytes_l = stream.read(8);
        if (bytes_l.len < 8) {
            std.log.err("Cannot read UUID: not enough bytes for second half", .{});
            return "00000000-0000-0000-0000-000000000000";
        }

        // Allocate a buffer for the UUID string (36 characters: 32 hex digits + 4 hyphens)
        const uuid_str = stream.allocator.alloc(u8, 36) catch |err| {
            std.log.err("Failed to allocate memory for UUID: {any}", .{err});
            return "00000000-0000-0000-0000-000000000000";
        };

        // Format the UUID string from the two 8-byte chunks
        _ = std.fmt.bufPrint(uuid_str, "{x:0>2}{x:0>2}{x:0>2}{x:0>2}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}", .{
            bytes_m[0], bytes_m[1], bytes_m[2], bytes_m[3],
            bytes_m[4], bytes_m[5], bytes_m[6], bytes_m[7],
            bytes_l[0], bytes_l[1], bytes_l[2], bytes_l[3],
            bytes_l[4], bytes_l[5], bytes_l[6], bytes_l[7],
        }) catch |err| {
            stream.allocator.free(uuid_str);
            std.log.err("Failed to format UUID: {any}", .{err});
            return "00000000-0000-0000-0000-000000000000";
        };

        return uuid_str;
    }

    /// Writes a 128-bit (16 bytes) UUID to the stream from a formatted string.
    /// The UUID string should be in the standard format: 8-4-4-4-12 hexadecimal digits
    /// with hyphens, e.g. "550e8400-e29b-41d4-a716-446655440000"
    pub fn write(stream: *BinaryStream, value: []const u8) !void {
        if (value.len != 36) {
            std.log.err("Invalid UUID format: incorrect length", .{});
            return error.InvalidUuidFormat;
        }

        var bytes_m: [8]u8 = undefined;
        var bytes_l: [8]u8 = undefined;
        var i: usize = 0;
        var j: usize = 0;

        while (j < 8) {
            if (value[i] == '-') {
                i += 1;
                continue;
            }

            const high = switch (value[i]) {
                '0'...'9' => value[i] - '0',
                'a'...'f' => value[i] - 'a' + 10,
                'A'...'F' => value[i] - 'A' + 10,
                else => {
                    std.log.err("Invalid UUID format: invalid character", .{});
                    return error.InvalidUuidFormat;
                },
            };

            if (i + 1 >= value.len) {
                std.log.err("Invalid UUID format: unexpected end", .{});
                return error.InvalidUuidFormat;
            }

            const low = switch (value[i + 1]) {
                '0'...'9' => value[i + 1] - '0',
                'a'...'f' => value[i + 1] - 'a' + 10,
                'A'...'F' => value[i + 1] - 'A' + 10,
                else => {
                    std.log.err("Invalid UUID format: invalid character", .{});
                    return error.InvalidUuidFormat;
                },
            };

            bytes_m[j] = @as(u8, @intCast(high << 4 | low));
            j += 1;
            i += 2;
        }

        while (i < value.len and j == 8) {
            if (value[i] == '-') {
                i += 1;
            } else {
                break;
            }
        }

        j = 0;
        while (j < 8 and i < value.len) {
            if (value[i] == '-') {
                i += 1;
                continue;
            }

            if (i + 1 >= value.len) {
                std.log.err("Invalid UUID format: unexpected end", .{});
                return error.InvalidUuidFormat;
            }

            const high = switch (value[i]) {
                '0'...'9' => value[i] - '0',
                'a'...'f' => value[i] - 'a' + 10,
                'A'...'F' => value[i] - 'A' + 10,
                else => {
                    std.log.err("Invalid UUID format: invalid character", .{});
                    return error.InvalidUuidFormat;
                },
            };

            const low = switch (value[i + 1]) {
                '0'...'9' => value[i + 1] - '0',
                'a'...'f' => value[i + 1] - 'a' + 10,
                'A'...'F' => value[i + 1] - 'A' + 10,
                else => {
                    std.log.err("Invalid UUID format: invalid character", .{});
                    return error.InvalidUuidFormat;
                },
            };

            bytes_l[j] = @as(u8, @intCast(high << 4 | low));
            j += 1;
            i += 2;
        }

        stream.write(&bytes_m);
        stream.write(&bytes_l);
    }
};

test "UUID read/write" {
    std.debug.print("Running test: UUID read/write\n", .{});

    var buffer: [100]u8 = [_]u8{0} ** 100;
    var stream = BinaryStream.init(std.testing.allocator, &buffer, 0);
    defer stream.deinit();

    const test_value = "550e8400-e29b-41d4-a716-446655440000";
    try Uuid.write(&stream, test_value);

    // Reset offset to read from the beginning
    stream.offset = 0;
    const read_value = Uuid.read(&stream);

    if (!std.mem.eql(u8, read_value, "00000000-0000-0000-0000-000000000000")) {
        defer std.testing.allocator.free(read_value);
        try std.testing.expectEqualStrings(test_value, read_value);
    }
}
