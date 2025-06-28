const std = @import("std");
const BinaryStream = @import("../../stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("../../enums/Endianess.zig").Endianess;

/// **UUID**
///
/// Represents a 128-bit (16 bytes) universally unique identifier.
/// Stored in two 8-byte chunks that are reversed when reading/writing.
/// The string representation uses the standard format: 8-4-4-4-12 hexadecimal digits
/// with hyphens, e.g. "550e8400-e29b-41d4-a716-446655440000"
pub const Uuid = struct {
    /// Reads a 128-bit (16 bytes) UUID from the stream and returns it as a formatted string.
    /// If there's an error reading the UUID, returns a default all-zero UUID and logs the error.
    pub fn read(stream: *BinaryStream) []const u8 {
        // Allocate a buffer for the UUID string (36 characters: 32 hex digits + 4 hyphens)
        var uuid_str = stream.allocator.alloc(u8, 36) catch |err| {
            std.log.err("Failed to allocate memory for UUID: {any}", .{err});
            return "00000000-0000-0000-0000-000000000000";
        };

        // Read the first 8 bytes and reverse them
        const bytes_m = stream.read(8);
        if (bytes_m.len < 8) {
            stream.allocator.free(uuid_str);
            std.log.err("Cannot read UUID: not enough bytes for first half", .{});
            return "00000000-0000-0000-0000-000000000000";
        }

        // Read the second 8 bytes and reverse them
        const bytes_l = stream.read(8);
        if (bytes_l.len < 8) {
            stream.allocator.free(uuid_str);
            std.log.err("Cannot read UUID: not enough bytes for second half", .{});
            return "00000000-0000-0000-0000-000000000000";
        }

        // Format the first chunk (8 bytes)
        var index: usize = 0;
        for (0..8) |i| {
            const byte = bytes_m[7 - i]; // Reverse order
            _ = std.fmt.bufPrint(uuid_str[index .. index + 2], "{x:0>2}", .{byte}) catch |err| {
                stream.allocator.free(uuid_str);
                std.log.err("Failed to format UUID: {any}", .{err});
                return "00000000-0000-0000-0000-000000000000";
            };
            index += 2;
            // Add hyphens at positions 8, 13, 18
            if (index == 8 or index == 13 or index == 18) {
                uuid_str[index] = '-';
                index += 1;
            }
        }

        // Format the second chunk (8 bytes)
        for (0..8) |i| {
            const byte = bytes_l[7 - i]; // Reverse order
            _ = std.fmt.bufPrint(uuid_str[index .. index + 2], "{x:0>2}", .{byte}) catch |err| {
                stream.allocator.free(uuid_str);
                std.log.err("Failed to format UUID: {any}", .{err});
                return "00000000-0000-0000-0000-000000000000";
            };
            index += 2;
            // Add hyphen at position 23
            if (index == 23) {
                uuid_str[index] = '-';
                index += 1;
            }
        }

        return uuid_str;
    }

    /// Writes a 128-bit (16 bytes) UUID to the stream from a formatted string.
    /// The UUID string should be in the standard format: 8-4-4-4-12 hexadecimal digits
    /// with hyphens, e.g. "550e8400-e29b-41d4-a716-446655440000"
    pub fn write(stream: *BinaryStream, value: []const u8) !void {
        // Validate the UUID string format (should be 36 chars with hyphens at specific positions)
        if (value.len != 36 or
            value[8] != '-' or value[13] != '-' or value[18] != '-' or value[23] != '-')
        {
            std.log.err("Invalid UUID format. Expected format: 8-4-4-4-12 with hyphens", .{});
            return error.InvalidUuidFormat;
        }

        // Convert UUID string to bytes (skipping hyphens)
        var bytes_m: [8]u8 = undefined;
        var bytes_l: [8]u8 = undefined;

        // First 8 bytes (before the third hyphen)
        var j: usize = 0;
        var k: usize = 0;
        while (j < 8) : (j += 1) {
            var hex_str: [2]u8 = undefined;

            // Skip hyphens
            if (k == 8 or k == 13) {
                k += 1;
            }

            hex_str[0] = value[k];
            hex_str[1] = value[k + 1];
            k += 2;

            // Parse hex string to byte
            bytes_m[7 - j] = try std.fmt.parseInt(u8, &hex_str, 16); // Store in reverse order
        }

        // Last 8 bytes (after the third hyphen)
        j = 0;
        // Skip to position after third hyphen
        k = 19;
        while (j < 8) : (j += 1) {
            var hex_str: [2]u8 = undefined;

            // Skip hyphen
            if (k == 23) {
                k += 1;
            }

            hex_str[0] = value[k];
            hex_str[1] = value[k + 1];
            k += 2;

            // Parse hex string to byte
            bytes_l[7 - j] = try std.fmt.parseInt(u8, &hex_str, 16); // Store in reverse order
        }

        // Write bytes to stream
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
