# BinaryStream

A powerful and flexible binary data manipulation library for Zig, providing easy-to-use stream-based reading and writing operations with support for various data types and endianness.

## Features

- 🚀 **High Performance**: Zero-copy operations where possible
- 📦 **Rich Type Support**: Integers, floats, strings, UUIDs, and variable-length encodings
- 🔄 **Endianness Control**: Support for both little-endian and big-endian operations
- 📏 **Variable-Length Integers**: VarInt, VarLong, ZigZag, and ZigZong encoding
- 🎯 **Stream-Based**: Automatic offset management for sequential operations
- 🛡️ **Memory Safe**: Proper memory management with clear ownership semantics

## Installation

Add BinaryStream to your `build.zig.zon`:

```sh
zig fetch --save git+https://github.com/SanctumTerra/BinaryStream#master
```

Then in your `build.zig`:

```zig
const binarystream_dep = b.dependency("BinaryStream", .{});
exe.root_module.addImport("BinaryStream", binarystream_dep.module("BinaryStream"));
```

## Quick Start

```zig
const std = @import("std");
const BinaryStream = @import("binarystream").BinaryStream;
const Endianess = @import("binarystream").Endianess;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create a new stream
    var stream = BinaryStream.init(allocator, null, null);
    defer stream.deinit();

    // Write some data
    stream.writeUint32(0x12345678, .Little);
    stream.writeString16("Hello, World!", .Little);
    stream.writeFloat32(3.14159, .Little);

    // Reset offset to read from beginning
    stream.offset = 0;

    // Read the data back
    const number = stream.readUint32(.Little);
    const text = stream.readString16(.Little);
    const pi = stream.readFloat32(.Little);

    std.debug.print("Number: 0x{X}\n", .{number});
    std.debug.print("Text: {s}\n", .{text});
    std.debug.print("Pi: {}\n", .{pi});
}
```

## API Reference

### Initialization

```zig
// Create empty stream
var stream = BinaryStream.init(allocator, null, null);

// Create stream with initial data
const initial_data = [_]u8{0x01, 0x02, 0x03, 0x04};
var stream = BinaryStream.init(allocator, &initial_data, null);

// Create stream with custom offset
var stream = BinaryStream.init(allocator, &initial_data, 10);

// Always remember to clean up
defer stream.deinit();
```

### Buffer Operations

```zig
// Get read-only view of buffer (zero-copy)
const buffer = stream.getBuffer();

// Write raw bytes
const data = [_]u8{0xDE, 0xAD, 0xBE, 0xEF};
stream.write(&data);

// Read raw bytes
const bytes = stream.read(4); // Read 4 bytes
```

### Integer Operations

#### Unsigned Integers
```zig
// 8-bit
stream.writeUint8(255);
const val8 = stream.readUint8();

// 16-bit with endianness
stream.writeUint16(65535, .Little);
stream.writeUShort(32767, .Big); // Alias for writeUint16
const val16 = stream.readUint16(.Little);

// 24-bit (3 bytes)
stream.writeUint24(16777215, .Little);
const val24 = stream.readUint24(.Little);

// 32-bit
stream.writeUint32(0xDEADBEEF, .Big);
const val32 = stream.readUint32(.Big);

// 64-bit
stream.writeUint64(0x123456789ABCDEF0, .Little);
stream.writeULong(9223372036854775807, .Little); // Alias for writeUint64
const val64 = stream.readUint64(.Little);
```

#### Signed Integers
```zig
// 8-bit
stream.writeInt8(-128);
stream.writeByte(127); // Alias for writeInt8
const val8 = stream.readInt8();

// 16-bit
stream.writeInt16(-32768, .Little);
stream.writeShort(32767, .Big); // Alias for writeInt16
const val16 = stream.readInt16(.Little);

// 24-bit (stored as i32, but only uses 3 bytes)
stream.writeInt24(-8388608, .Little);
const val24 = stream.readInt24(.Little);

// 32-bit
stream.writeInt32(-2147483648, .Big);
const val32 = stream.readInt32(.Big);

// 64-bit
stream.writeInt64(-9223372036854775808, .Little);
stream.writeLong(9223372036854775807, .Little); // Alias for writeInt64
const val64 = stream.readInt64(.Little);
```

### Variable-Length Integers

```zig
// VarInt (u32) - uses 1-5 bytes depending on value
stream.writeVarInt(300);
const varint = stream.readVarInt();

// VarLong (u64) - uses 1-10 bytes depending on value
stream.writeVarLong(9223372036854775807);
const varlong = stream.readVarLong();

// ZigZag encoding for signed integers (i32)
stream.writeZigZag(-12345);
const zigzag = stream.readZigZag();

// ZigZong encoding for signed long integers (i64)
stream.writeZigZong(-1234567890123456789);
const zigzong = stream.readZigZong();
```

### Floating Point Numbers

```zig
// 32-bit float
stream.writeFloat32(3.14159, .Little);
const f32_val = stream.readFloat32(.Little);

// 64-bit double
stream.writeFloat64(2.71828182845904523536, .Big);
const f64_val = stream.readFloat64(.Big);
```

### String Operations

```zig
// String with 16-bit length prefix
stream.writeString16("Hello, World!", .Little);
const str16 = stream.readString16(.Little);

// String with 32-bit length prefix
stream.writeString32("Longer string here", .Big);
const str32 = stream.readString32(.Big);

// Variable-length string (VarInt length prefix)
stream.writeVarString("Variable length string");
const varstr = stream.readVarString();
```

### Other Data Types

```zig
// Boolean (stored as single byte)
stream.writeBool(true);
const boolean = stream.readBool();

// UUID (16 bytes)
const uuid = [16]u8{0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10};
stream.writeUuid(uuid);
const read_uuid = stream.readUuid();
```

### Endianness

The library supports both little-endian and big-endian byte ordering:

```zig
const Endianess = @import("binarystream").Endianess;

// Little-endian (Intel/AMD x86, ARM in little-endian mode)
stream.writeUint32(0x12345678, .Little);
// Bytes: [0x78, 0x56, 0x34, 0x12]

// Big-endian (Network byte order, some ARM configurations)
stream.writeUint32(0x12345678, .Big);
// Bytes: [0x12, 0x34, 0x56, 0x78]
```

## Memory Management

BinaryStream manages its own internal buffer, but you're responsible for:

1. **Stream Lifecycle**: Always call `deinit()` when done
2. **String Data**: String read operations return slices into the stream's buffer - they're valid until the stream is modified or destroyed
3. **Buffer Access**: `getBuffer()` returns a slice to internal data - don't modify it directly

```zig
var stream = BinaryStream.init(allocator, null, null);
defer stream.deinit(); // ✅ Always clean up

// String data is valid as long as stream exists
stream.writeString16("test", .Little);
stream.offset = 0;
const text = stream.readString16(.Little); // Points to internal buffer
// ✅ Use 'text' here while stream is alive

// ❌ Don't do this - 'text' becomes invalid
stream.deinit();
// std.debug.print("{s}", .{text}); // Undefined behavior!
```

## Advanced Usage

### Working with Existing Data

```zig
// Parse existing binary data
const existing_data = [_]u8{0x01, 0x02, 0x03, 0x04};
var stream = BinaryStream.init(allocator, &existing_data, null);
defer stream.deinit();

const value = stream.readUint32(.Little);
```

### Custom Offset Management

```zig
var stream = BinaryStream.init(allocator, null, null);
defer stream.deinit();

// Write some data
stream.writeUint32(0x12345678, .Little);
stream.writeUint32(0x9ABCDEF0, .Little);

// Reset to beginning
stream.offset = 0;

// Read first value
const first = stream.readUint32(.Little);

// Skip to specific position
stream.offset = 4;

// Read second value
const second = stream.readUint32(.Little);
```

## Common Patterns

### Protocol Implementation

```zig
// Writing a network packet
fn writePacket(stream: *BinaryStream, packet_type: u8, data: []const u8) void {
    stream.writeUint8(packet_type);           // Packet type
    stream.writeUint32(@intCast(data.len), .Little); // Data length
    stream.write(data);                       // Payload
}

// Reading a network packet
fn readPacket(stream: *BinaryStream) struct { type: u8, data: []const u8 } {
    const packet_type = stream.readUint8();
    const data_len = stream.readUint32(.Little);
    const data = stream.read(data_len);
    return .{ .type = packet_type, .data = data };
}
```

### File Format Parsing

```zig
// Parse a simple file header
fn parseFileHeader(stream: *BinaryStream) !FileHeader {
    const magic = stream.readUint32(.Little);
    if (magic != 0x12345678) return error.InvalidMagic;
    
    const version = stream.readUint16(.Little);
    const flags = stream.readUint16(.Little);
    const timestamp = stream.readUint64(.Little);
    const filename = stream.readString16(.Little);
    
    return FileHeader{
        .version = version,
        .flags = flags,
        .timestamp = timestamp,
        .filename = filename,
    };
}
```

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the MIT License.