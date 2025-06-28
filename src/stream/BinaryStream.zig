const std = @import("std");
const Endianess = @import("../enums/Endianess.zig").Endianess;

pub const BinaryStream = struct {
    payload: std.ArrayList(u8),
    offset: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, payload: ?[]const u8, offset: ?usize) BinaryStream {
        var array_list = std.ArrayList(u8).init(allocator);

        // If payload is provided, append it to the ArrayList
        if (payload) |data| {
            array_list.appendSlice(data) catch |err| {
                std.debug.print("Failed to initialize binary stream: {}\n", .{err});
                return BinaryStream{
                    .allocator = allocator,
                    .payload = std.ArrayList(u8).init(allocator),
                    .offset = offset orelse 0,
                };
            };
        }

        return BinaryStream{
            .allocator = allocator,
            .payload = array_list,
            .offset = offset orelse 0,
        };
    }

    /// Frees all memory allocated by this BinaryStream
    pub fn deinit(self: *BinaryStream) void {
        self.payload.deinit();
    }

    /// Reads a specified number of bytes from the stream.
    ///
    /// If there are not enough bytes left, returns as many as possible.
    pub fn read(self: *BinaryStream, length: usize) []const u8 {
        if (self.offset + length > self.payload.items.len) {
            const safe_length = if (self.offset < self.payload.items.len)
                self.payload.items.len - self.offset
            else
                0;

            const value = if (safe_length > 0)
                self.payload.items[self.offset..][0..safe_length]
            else
                &[_]u8{};

            self.offset += safe_length;
            return value;
        }

        const value = self.payload.items[self.offset .. self.offset + length];
        self.offset += length;
        return value;
    }

    /// Writes a byte slice to the stream at the current offset.
    ///
    /// If there isn't enough space in the payload, writes as much as possible.
    pub fn write(self: *BinaryStream, value: []const u8) void {
        const remaining_space = if (self.offset < self.payload.items.len)
            self.payload.items.len - self.offset
        else
            0;

        // Calculate how many bytes we can actually write
        const bytes_to_write = @min(value.len, remaining_space);

        // Only perform the write if we have space
        if (bytes_to_write > 0) {
            @memcpy(self.payload.items[self.offset..][0..bytes_to_write], value[0..bytes_to_write]);
            self.offset += bytes_to_write;
        }
    }
};
