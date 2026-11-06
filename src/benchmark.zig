const std = @import("std");
const BinaryStream = @import("stream/BinaryStream.zig").BinaryStream;
const Endianess = @import("enums/Endianess.zig").Endianess;

const ITERATIONS = 1_000;

const TimeFormat = struct { value: f64, unit: []const u8 };

var io_instance: std.Io = undefined;

const Result = struct {
    write_ns: i96,
    read_ns: i96,
};

fn formatTime(ns: i96) TimeFormat {
    const ns_f = @as(f64, @floatFromInt(ns));
    const abs_ns = if (ns_f < 0) -ns_f else ns_f;

    if (abs_ns < 1_000) return .{ .value = ns_f, .unit = "ns" };
    if (abs_ns < 1_000_000) return .{ .value = ns_f / 1_000.0, .unit = "us" };
    if (abs_ns < 1_000_000_000) return .{ .value = ns_f / 1_000_000.0, .unit = "ms" };
    return .{ .value = ns_f / 1_000_000_000.0, .unit = "s " };
}

fn printResult(name: []const u8, result: Result) void {
    const w_total = formatTime(result.write_ns);
    const r_total = formatTime(result.read_ns);
    const w_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(result.write_ns)) / 1_000_000_000.0);
    const r_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(result.read_ns)) / 1_000_000_000.0);
    std.debug.print("  {s:<12}\n", .{name});
    std.debug.print("    write: {d:>8.2} {s:<2} total, {d:>6.0} ns/op, {d:>12.0} ops/s\n", .{ w_total.value, w_total.unit, @as(f64, @floatFromInt(result.write_ns)) / @as(f64, @floatFromInt(ITERATIONS)), w_ops });
    std.debug.print("    read:  {d:>8.2} {s:<2} total, {d:>6.0} ns/op, {d:>12.0} ops/s\n", .{ r_total.value, r_total.unit, @as(f64, @floatFromInt(result.read_ns)) / @as(f64, @floatFromInt(ITERATIONS)), r_ops });
}

// === Unsigned Integer Benchmarks ===
fn benchUint8(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeUint8(0xFF);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint8();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchUint16(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeUint16(0xABCD, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint16(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchUint24(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeUint24(0xABCDEF, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint24(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchUint32(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeUint32(0x12345678, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint32(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchUint64(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeUint64(0xDEADBEEFCAFEBABE, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readUint64(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchBool(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeBool(true);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readBool();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

// === Signed Integer Benchmarks ===
fn benchInt8(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeInt8(-42);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt8();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchInt16(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeInt16(-1234, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt16(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchInt24(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeInt24(-123456, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt24(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchInt32(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeInt32(-987654, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt32(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchInt64(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeInt64(-9876543210, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readInt64(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

// === VarInt Benchmarks ===
fn benchVarInt(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeVarInt(300);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readVarInt();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchVarLong(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeVarLong(123456789);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readVarLong();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchZigZag(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeZigZag(-12345);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readZigZag();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchZigZong(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeZigZong(-123456789);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readZigZong();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

// === Float Benchmarks ===
fn benchFloat32(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeFloat32(3.14159, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readFloat32(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

fn benchFloat64(stream: *BinaryStream) !Result {
    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        try stream.writeFloat64(2.71828182845, .Big);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..ITERATIONS) |_| {
        _ = try stream.readFloat64(.Big);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns, .read_ns = read_ns };
}

// === String Benchmarks ===
fn benchVarString(stream: *BinaryStream) !Result {
    const test_str = "Hello, BinaryStream!";
    const str_iterations = ITERATIONS / 2;

    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..str_iterations) |_| {
        try stream.writeVarString(test_str);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..str_iterations) |_| {
        _ = try stream.readVarString();
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns * 2, .read_ns = read_ns * 2 };
}

// === Raw Operations ===
fn benchRaw(stream: *BinaryStream) !Result {
    const data = "The quick brown fox jumps over the lazy dog";
    const raw_iterations = ITERATIONS / 3;

    const write_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..raw_iterations) |_| {
        try stream.write(data);
    }
    const write_ns = write_timer.untilNow(io_instance, .awake).nanoseconds;

    stream.offset = 0;
    const read_timer = std.Io.Timestamp.now(io_instance, .awake);
    for (0..raw_iterations) |_| {
        _ = stream.read(data.len);
    }
    const read_ns = read_timer.untilNow(io_instance, .awake).nanoseconds;

    return .{ .write_ns = write_ns * 3, .read_ns = read_ns * 3 };
}

pub fn main(init: std.process.Init) !void {
    io_instance = init.io;
    var gpa: std.heap.SafeAllocator = .init(std.heap.page_allocator, .{});
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("\n", .{});
    std.debug.print("============================================================\n", .{});
    std.debug.print("        BinaryStream Benchmarks (Pure Read/Write)            \n", .{});
    std.debug.print("        Iterations: {d:<10}                            \n", .{ITERATIONS});
    std.debug.print("============================================================\n", .{});

    // Unsigned Integers
    std.debug.print("\n-- Unsigned Integers ---------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint8(&stream);
        printResult("Uint8", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint16(&stream);
        printResult("Uint16", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint24(&stream);
        printResult("Uint24", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint32(&stream);
        printResult("Uint32", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchUint64(&stream);
        printResult("Uint64", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchBool(&stream);
        printResult("Bool", r);
    }

    // Signed Integers
    std.debug.print("\n-- Signed Integers -----------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt8(&stream);
        printResult("Int8", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt16(&stream);
        printResult("Int16", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt24(&stream);
        printResult("Int24", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt32(&stream);
        printResult("Int32", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchInt64(&stream);
        printResult("Int64", r);
    }

    // Variable-length Integers
    std.debug.print("\n-- Variable-length Integers --------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchVarInt(&stream);
        printResult("VarInt", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchVarLong(&stream);
        printResult("VarLong", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchZigZag(&stream);
        printResult("ZigZag", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchZigZong(&stream);
        printResult("ZigZong", r);
    }

    // Floats
    std.debug.print("\n-- Floating Point ------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchFloat32(&stream);
        printResult("Float32", r);
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchFloat64(&stream);
        printResult("Float64", r);
    }

    // Strings
    std.debug.print("\n-- Strings -------------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchVarString(&stream);
        printResult("VarString", r);
    }

    // Raw
    std.debug.print("\n-- Raw Operations ------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        const r = try benchRaw(&stream);
        printResult("Raw (43 bytes)", r);
    }

    // toOwnedSlice / getBuffer benchmarks
    std.debug.print("\n-- Buffer Export -------------------------------------------\n", .{});
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        try stream.writeUint64(0xDEADBEEF, .Big);
        try stream.writeVarString("Test packet data");

        const get_timer = std.Io.Timestamp.now(io_instance, .awake);
        for (0..ITERATIONS) |_| {
            const buf = stream.getBuffer();
            std.mem.doNotOptimizeAway(buf.ptr);
        }
        const get_ns = get_timer.untilNow(io_instance, .awake).nanoseconds;
        const get_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(get_ns)) / 1_000_000_000.0);
        std.debug.print("  getBuffer:     {d:>6.0} ns/op, {d:>12.0} ops/s (zero-copy)\n", .{ @as(f64, @floatFromInt(get_ns)) / @as(f64, @floatFromInt(ITERATIONS)), get_ops });
    }
    {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();
        try stream.writeUint64(0xDEADBEEF, .Big);
        try stream.writeVarString("Test packet data");
        const data_len = stream.written;

        const owned_timer = std.Io.Timestamp.now(io_instance, .awake);
        for (0..ITERATIONS) |_| {
            const owned = try stream.getBufferOwned(allocator);
            allocator.free(owned);
        }
        const owned_ns = owned_timer.untilNow(io_instance, .awake).nanoseconds;
        const owned_ops = @as(f64, @floatFromInt(ITERATIONS)) / (@as(f64, @floatFromInt(owned_ns)) / 1_000_000_000.0);
        std.debug.print("  getBufferOwned:{d:>6.0} ns/op, {d:>12.0} ops/s ({d} bytes, alloc+copy+free)\n", .{ @as(f64, @floatFromInt(owned_ns)) / @as(f64, @floatFromInt(ITERATIONS)), owned_ops, data_len });
    }

    std.debug.print("\n", .{});
}
