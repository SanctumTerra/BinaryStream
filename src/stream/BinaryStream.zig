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
    /// If the offset is beyond the current payload size, it will grow the payload.
    pub fn write(self: *BinaryStream, value: []const u8) void {
        // If we're writing past the end of the current buffer, we need to expand
        if (self.offset > self.payload.items.len) {
            // Add padding zeros to reach the offset
            const padding_needed = self.offset - self.payload.items.len;
            self.payload.appendNTimes(0, padding_needed) catch |err| {
                std.log.err("Failed to grow payload: {}", .{err});
                return;
            };
        }

        if (self.offset == self.payload.items.len) {
            // Appending at the end
            self.payload.appendSlice(value) catch |err| {
                std.log.err("Failed to append to payload: {}", .{err});
                return;
            };
            self.offset += value.len;
        } else {
            // Writing within the existing buffer
            const end_pos = self.offset + value.len;

            if (end_pos > self.payload.items.len) {
                // Need to grow the buffer to fit the entire value
                const additional_bytes = end_pos - self.payload.items.len;
                self.payload.appendNTimes(0, additional_bytes) catch |err| {
                    std.log.err("Failed to grow payload: {}", .{err});
                    return;
                };
            }

            // Copy the value into the buffer
            @memcpy(self.payload.items[self.offset..end_pos], value);
            self.offset = end_pos;
        }
    }

    // Unsigned integer write methods
    pub fn writeUint8(self: *BinaryStream, value: u8) void {
        const Uint8 = @import("../types/unsigned/UInt8.zig").Uint8;
        Uint8.write(self, value);
    }

    pub fn writeUint16(self: *BinaryStream, value: u16, endian: Endianess) void {
        const Uint16 = @import("../types/unsigned/UInt16.zig").Uint16;
        Uint16.write(self, value, endian);
    }

    pub fn writeUint24(self: *BinaryStream, value: u24, endian: Endianess) void {
        const Uint24 = @import("../types/unsigned/Uint24.zig").Uint24;
        Uint24.write(self, value, endian);
    }

    pub fn writeUint32(self: *BinaryStream, value: u32, endian: Endianess) void {
        const Uint32 = @import("../types/unsigned/UInt32.zig").Uint32;
        Uint32.write(self, value, endian);
    }

    pub fn writeUint64(self: *BinaryStream, value: u64, endian: Endianess) void {
        const Uint64 = @import("../types/unsigned/UInt64.zig").Uint64;
        Uint64.write(self, value, endian);
    }

    pub fn writeULong(self: *BinaryStream, value: u64, endian: Endianess) void {
        const ULong = @import("../types/unsigned/ULong.zig").ULong;
        ULong.write(self, value, endian);
    }

    pub fn writeUShort(self: *BinaryStream, value: u16, endian: Endianess) void {
        const UShort = @import("../types/unsigned/UShort.zig").UShort;
        UShort.write(self, value, endian);
    }

    pub fn writeBool(self: *BinaryStream, value: bool) void {
        const Bool = @import("../types/unsigned/Bool.zig").Bool;
        Bool.write(self, value);
    }

    // Signed integer write methods
    pub fn writeByte(self: *BinaryStream, value: i8) void {
        const Byte = @import("../types/signed/Byte.zig").Byte;
        Byte.write(self, value);
    }

    pub fn writeInt8(self: *BinaryStream, value: i8) void {
        const Int8 = @import("../types/signed/Int8.zig").Int8;
        Int8.write(self, value);
    }

    pub fn writeInt16(self: *BinaryStream, value: i16, endian: Endianess) void {
        const Int16 = @import("../types/signed/Int16.zig").Int16;
        Int16.write(self, value, endian);
    }

    pub fn writeInt24(self: *BinaryStream, value: i32, endian: Endianess) void {
        const Int24 = @import("../types/signed/Int24.zig").Int24;
        Int24.write(self, value, endian);
    }

    pub fn writeInt32(self: *BinaryStream, value: i32, endian: Endianess) void {
        const Int32 = @import("../types/signed/Int32.zig").Int32;
        Int32.write(self, value, endian);
    }

    pub fn writeInt64(self: *BinaryStream, value: i64, endian: Endianess) void {
        const Int64 = @import("../types/signed/Int64.zig").Int64;
        Int64.write(self, value, endian);
    }

    pub fn writeLong(self: *BinaryStream, value: i64, endian: Endianess) void {
        const Long = @import("../types/signed/Long.zig").Long;
        Long.write(self, value, endian);
    }

    pub fn writeShort(self: *BinaryStream, value: i16, endian: Endianess) void {
        const Short = @import("../types/signed/Short.zig").Short;
        Short.write(self, value, endian);
    }

    // Variable-length integer write methods
    pub fn writeVarInt(self: *BinaryStream, value: u32) void {
        const VarInt = @import("../types/varint/VarInt.zig").VarInt;
        VarInt.write(self, value);
    }

    pub fn writeVarLong(self: *BinaryStream, value: u64) void {
        const VarLong = @import("../types/varint/VarLong.zig").VarLong;
        VarLong.write(self, value, null);
    }

    pub fn writeZigZag(self: *BinaryStream, value: i32) void {
        const ZigZag = @import("../types/varint/ZigZag.zig").ZigZag;
        ZigZag.write(self, value);
    }

    pub fn writeZigZong(self: *BinaryStream, value: i64) void {
        const ZigZong = @import("../types/varint/ZigZong.zig").ZigZong;
        ZigZong.write(self, value);
    }

    // String write methods
    pub fn writeString16(self: *BinaryStream, value: []const u8, endian: Endianess) void {
        const String16 = @import("../types/string/String16.zig").String16;
        String16.write(self, value, endian);
    }

    pub fn writeString32(self: *BinaryStream, value: []const u8, endian: Endianess) void {
        const String32 = @import("../types/string/String32.zig").String32;
        String32.write(self, value, endian);
    }

    pub fn writeVarString(self: *BinaryStream, value: []const u8) void {
        const VarString = @import("../types/string/VarString.zig").VarString;
        VarString.write(self, value);
    }

    pub fn writeUuid(self: *BinaryStream, value: [16]u8) void {
        const Uuid = @import("../types/string/Uuid.zig").Uuid;
        Uuid.write(self, value);
    }

    // Float write methods
    pub fn writeFloat32(self: *BinaryStream, value: f32, endian: Endianess) void {
        const Float32 = @import("../types/float/Float32.zig").Float32;
        Float32.write(self, value, endian);
    }

    pub fn writeFloat64(self: *BinaryStream, value: f64, endian: Endianess) void {
        const Float64 = @import("../types/float/Float64.zig").Float64;
        Float64.write(self, value, endian);
    }

    // Unsigned integer read methods
    pub fn readUint8(self: *BinaryStream) u8 {
        const Uint8 = @import("../types/unsigned/UInt8.zig").Uint8;
        return Uint8.read(self);
    }

    pub fn readUint16(self: *BinaryStream, endian: Endianess) u16 {
        const Uint16 = @import("../types/unsigned/UInt16.zig").Uint16;
        return Uint16.read(self, endian);
    }

    pub fn readUint24(self: *BinaryStream, endian: Endianess) u24 {
        const Uint24 = @import("../types/unsigned/Uint24.zig").Uint24;
        return Uint24.read(self, endian);
    }

    pub fn readUint32(self: *BinaryStream, endian: Endianess) u32 {
        const Uint32 = @import("../types/unsigned/UInt32.zig").Uint32;
        return Uint32.read(self, endian);
    }

    pub fn readUint64(self: *BinaryStream, endian: Endianess) u64 {
        const Uint64 = @import("../types/unsigned/UInt64.zig").Uint64;
        return Uint64.read(self, endian);
    }

    pub fn readULong(self: *BinaryStream, endian: Endianess) u64 {
        const ULong = @import("../types/unsigned/ULong.zig").ULong;
        return ULong.read(self, endian);
    }

    pub fn readUShort(self: *BinaryStream, endian: Endianess) u16 {
        const UShort = @import("../types/unsigned/UShort.zig").UShort;
        return UShort.read(self, endian);
    }

    pub fn readBool(self: *BinaryStream) bool {
        const Bool = @import("../types/unsigned/Bool.zig").Bool;
        return Bool.read(self);
    }

    // Signed integer read methods
    pub fn readByte(self: *BinaryStream) i8 {
        const Byte = @import("../types/signed/Byte.zig").Byte;
        return Byte.read(self);
    }

    pub fn readInt8(self: *BinaryStream) i8 {
        const Int8 = @import("../types/signed/Int8.zig").Int8;
        return Int8.read(self);
    }

    pub fn readInt16(self: *BinaryStream, endian: Endianess) i16 {
        const Int16 = @import("../types/signed/Int16.zig").Int16;
        return Int16.read(self, endian);
    }

    pub fn readInt24(self: *BinaryStream, endian: Endianess) i32 {
        const Int24 = @import("../types/signed/Int24.zig").Int24;
        return Int24.read(self, endian);
    }

    pub fn readInt32(self: *BinaryStream, endian: Endianess) i32 {
        const Int32 = @import("../types/signed/Int32.zig").Int32;
        return Int32.read(self, endian);
    }

    pub fn readInt64(self: *BinaryStream, endian: Endianess) i64 {
        const Int64 = @import("../types/signed/Int64.zig").Int64;
        return Int64.read(self, endian);
    }

    pub fn readLong(self: *BinaryStream, endian: Endianess) i64 {
        const Long = @import("../types/signed/Long.zig").Long;
        return Long.read(self, endian);
    }

    pub fn readShort(self: *BinaryStream, endian: Endianess) i16 {
        const Short = @import("../types/signed/Short.zig").Short;
        return Short.read(self, endian);
    }

    // Variable-length integer read methods
    pub fn readVarInt(self: *BinaryStream) u32 {
        const VarInt = @import("../types/varint/VarInt.zig").VarInt;
        return VarInt.read(self);
    }

    pub fn readVarLong(self: *BinaryStream) u64 {
        const VarLong = @import("../types/varint/VarLong.zig").VarLong;
        return VarLong.read(self, null);
    }

    pub fn readZigZag(self: *BinaryStream) i32 {
        const ZigZag = @import("../types/varint/ZigZag.zig").ZigZag;
        return ZigZag.read(self);
    }

    pub fn readZigZong(self: *BinaryStream) i64 {
        const ZigZong = @import("../types/varint/ZigZong.zig").ZigZong;
        return ZigZong.read(self);
    }

    // String read methods
    pub fn readString16(self: *BinaryStream, endian: Endianess) []const u8 {
        const String16 = @import("../types/string/String16.zig").String16;
        return String16.read(self, endian);
    }

    pub fn readString32(self: *BinaryStream, endian: Endianess) []const u8 {
        const String32 = @import("../types/string/String32.zig").String32;
        return String32.read(self, endian);
    }

    pub fn readVarString(self: *BinaryStream) []const u8 {
        const VarString = @import("../types/string/VarString.zig").VarString;
        return VarString.read(self);
    }

    pub fn readUuid(self: *BinaryStream) [16]u8 {
        const Uuid = @import("../types/string/Uuid.zig").Uuid;
        return Uuid.read(self);
    }

    // Float read methods
    pub fn readFloat32(self: *BinaryStream, endian: Endianess) f32 {
        const Float32 = @import("../types/float/Float32.zig").Float32;
        return Float32.read(self, endian);
    }

    pub fn readFloat64(self: *BinaryStream, endian: Endianess) f64 {
        const Float64 = @import("../types/float/Float64.zig").Float64;
        return Float64.read(self, endian);
    }
};
