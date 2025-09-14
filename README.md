<p align="center" style="font-size: 54px; color: #fb8600ff;"> BinaryStream </p>

<p align="center" style="font-size: 24px;" > A fast, reliable, easy to use data manipulation library for Zig. <p>

----


<p align="center" style="color: #ffffffff; font-size: 48px; padding-top: 10%;"> Usage  </p> 

<p align="left" style="color: #cdcacaff; font-size: 16px; padding-top: 1%;">Numbers: Writing && Reading  </p> 

```ts
    const BinaryStream = @import("binarystream").BinaryStream;
    const Endianess = @import("binarystream").Endianess;
    const VarInt = @import("binarystream").VarInt;

    // As a first step we must create a new instance of the BinaryStream
    var stream = BinaryStream.init(std.testing.allocator, null, null);
    // We must defer a deinit, this avoids memory leaks.
    defer stream.deinit();
    
    // Writing data is not complicated, here is an example of how to write a Packet ID.
    const ID: u32 = 0x1234;
    // Writing it to stream using Data Types. 
    try VarInt.write(&stream, packet_id);

    // Lets reset the offset back to 0 before we read.
    stream.offset = 0;

    // Now the reading part
    const read_packet_id = try VarInt.read(&stream);
    std.debug.print("Read Packet {d}", .{read_packet_id});
```

<p align="left" style="color: #cdcacaff; font-size: 16px; padding-top: 1%;">Strings: Writing && Reading  </p>

```ts
    // VarString import.
    const VarString = @import("binarystream").VarString;

    // Stream initialization is the same
    const test_string = "Test string";
    try VarString.write(&stream, test_string);

    // Lets reset the offset back to 0 before we read.
    stream.offset = 0;
    const read_string = try VarString.read(&stream);

    // We need to de-allocate strings, as they are owned buffers.
    defer allocator.free(read_string);

```