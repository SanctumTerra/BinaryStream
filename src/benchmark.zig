const std = @import("std");
const BinaryStream = @import("stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("enums/Endianess.zig").Endianess;

const ITERATIONS = 1_000;

const TimeFormat = struct { value: f64, unit: []const u8 };

fn formatTime(ns: u64) TimeFormat {
    if (ns < 1_000) return .{ .value = @floatFromInt(ns), .unit = "ns" };
    if (ns < 1_000_000) return .{ .value = @as(f64, @floatFromInt(ns)) / 1_000.0, .unit = "us" };
    if (ns < 1_000_000_000) return .{ .value = @as(f64, @floatFromInt(ns)) / 1_000_000.0, .unit = "ms" };
    return .{ .value = @as(f64, @floatFromInt(ns)) / 1_000_000_000.0, .unit = "s " };
}

fn printResult(name: []const u8, write_ns: u64, read_ns: u64) void {
    const w_total = formatTime(write_ns);
    const r_total = formatTime(read_ns);
    const w_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(write_ns)) / 1_000_000_000.0);
    const r_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(read_ns)) / 1_000_000_000.0);
    std.debug.print("  {s:<12}\n", .{name});
    std.debug.print("    write: {d:>8.2} {s:<2} total, {d:>6.0} ns/op, {d:>12.0} ops/s\n", .{ w_total.value, w_total.unit, @as(f64, @floatFromInt(write_ns)) / @as(f64, @floatFromInt(ITERATIONS)), w_ops });
    std.debug.print("    read:  {d:>8.2} {s:<2} total, {d:>6.0} ns/op, {d:>12.0} ops/s\n", .{ r_total.value, r_total.unit, @as(f64, @floatFromInt(read_ns)) / @as(f64, @floatFromInt(ITERATIONS)), r_ops });
}

// === Unsigned Integer Benchmarks ===
fn benchUint8(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeUint8(0xFF);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint8();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchUint16(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeUint16(0xABCD, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint16(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchUint24(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeUint24(0xABCDEF, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint24(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchUint32(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeUint32(0x12345678, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint32(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchUint64(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeUint64(0xDEADBEEFCAFEBABE, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint64(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchBool(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeBool(true);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readBool();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

// === Signed Integer Benchmarks ===
fn benchInt8(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeInt8(-42);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt8();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchInt16(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeInt16(-1234, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt16(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchInt24(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeInt24(-123456, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt24(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchInt32(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeInt32(-987654, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt32(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchInt64(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeInt64(-9876543210, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt64(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

// === VarInt Benchmarks ===
fn benchVarInt(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeVarInt(300);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readVarInt();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchVarLong(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeVarLong(123456789);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readVarLong();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchZigZag(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeZigZag(-12345);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readZigZag();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchZigZong(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeZigZong(-123456789);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readZigZong();
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

// === Float Benchmarks ===
fn benchFloat32(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeFloat32(3.14159, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readFloat32(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

fn benchFloat64(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    var write_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        try stream.writeFloat64(2.71828182845, .Big);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..ITERATIONS) |_| {
        _ = try stream.readFloat64(.Big);
    }
    return .{ .write = write_ns, .read = read_timer.read() };
}

// === String Benchmarks ===
fn benchVarString(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    const test_str = "Hello, BinaryStream!";
    const str_iterations = ITERATIONS / 2; // Strings use more space

    var write_timer = try std.time.Timer.start();
    for (0..str_iterations) |_| {
        try stream.writeVarString(test_str);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..str_iterations) |_| {
        _ = try stream.readVarString();
    }
    const read_ns = read_timer.read();

    // Scale to match ITERATIONS for consistent reporting
    return .{ .write = write_ns * 2, .read = read_ns * 2 };
}

// === Raw Operations ===
fn benchRaw(stream: *BinaryStream) !struct { write: u64, read: u64 } {
    const data = "The quick brown fox jumps over the lazy dog";
    const raw_iterations = ITERATIONS / 3; // Raw uses more space

    var write_timer = try std.time.Timer.start();
    for (0..raw_iterations) |_| {
        try stream.write(data);
    }
    const write_ns = write_timer.read();

    stream.offset = 0;
    var read_timer = try std.time.Timer.start();
    for (0..raw_iterations) |_| {
        _ = stream.read(data.len);
    }
    const read_ns = read_timer.read();

    // Scale to match ITERATIONS for consistent reporting
    return .{ .write = write_ns * 3, .read = read_ns * 3 };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("\n", .{});
    std.debug.print("============================================================\n", .{});
    std.debug.print("       BinaryStream Benchmarks (Pure Read/Write)            \n", .{});
    std.debug.print("       Iterations: {d:<10}                               \n", .{ITERATIONS});
    std.debug.print("============================================================\n", .{});

    // Unsigned Integers
    std.debug.print("\n-- Unsigned Integers ---------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint8(&stream);
        printResult("Uint8", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint16(&stream);
        printResult("Uint16", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint24(&stream);
        printResult("Uint24", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint32(&stream);
        printResult("Uint32", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint64(&stream);
        printResult("Uint64", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchBool(&stream);
        printResult("Bool", r.write, r.read);
    }

    // Signed Integers
    std.debug.print("\n-- Signed Integers -----------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt8(&stream);
        printResult("Int8", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt16(&stream);
        printResult("Int16", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt24(&stream);
        printResult("Int24", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt32(&stream);
        printResult("Int32", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt64(&stream);
        printResult("Int64", r.write, r.read);
    }

    // Variable-length Integers
    std.debug.print("\n-- Variable-length Integers --------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchVarInt(&stream);
        printResult("VarInt", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchVarLong(&stream);
        printResult("VarLong", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchZigZag(&stream);
        printResult("ZigZag", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchZigZong(&stream);
        printResult("ZigZong", r.write, r.read);
    }

    // Floats
    std.debug.print("\n-- Floating Point ------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchFloat32(&stream);
        printResult("Float32", r.write, r.read);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchFloat64(&stream);
        printResult("Float64", r.write, r.read);
    }

    // Strings
    std.debug.print("\n-- Strings -------------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchVarString(&stream);
        printResult("VarString", r.write, r.read);
    }

    // Raw
    std.debug.print("\n-- Raw Operations ------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchRaw(&stream);
        printResult("Raw (43 bytes)", r.write, r.read);
    }

    // toOwnedSlice / getBuffer benchmarks
    std.debug.print("\n-- Buffer Export -------------------------------------------\n", .{});
    {
        // Benchmark getBuffer (no allocation, just returns slice)
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        // Write some data first
        try stream.writeUint64(0xDEADBEEF, .Big);
        try stream.writeVarString("Test packet data");

        var timer = try std.time.Timer.start();
        for (0..ITERATIONS) |_| {
            const buf = stream.getBuffer();
            std.mem.doNotOptimizeAway(buf.ptr);
        }
        const get_ns = timer.read();
        const get_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(get_ns)) / 1_000_000_000.0);
        std.debug.print("  getBuffer:     {d:>6.0} ns/op, {d:>12.0} ops/s (zero-copy)\n", .{ @as(f64, @floatFromInt(get_ns)) / @as(f64, @floatFromInt(ITERATIONS)), get_ops });
    }
    {
        // Benchmark getBufferOwned - JUST the copy operation (stream stays intact)
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        try stream.writeUint64(0xDEADBEEF, .Big);
        try stream.writeVarString("Test packet data");
        const data_len = stream.written;

        var timer = try std.time.Timer.start();
        for (0..ITERATIONS) |_| {
            const owned = try stream.getBufferOwned(allocator);
            allocator.free(owned);
        }
        const owned_ns = timer.read();
        const owned_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(owned_ns)) / 1_000_000_000.0);
        std.debug.print("  getBufferOwned:{d:>6.0} ns/op, {d:>12.0} ops/s ({d} bytes, alloc+copy+free)\n", .{ @as(f64, @floatFromInt(owned_ns)) / @as(f64, @floatFromInt(ITERATIONS)), owned_ops, data_len });
    }

    std.debug.print("\n", .{});
}
