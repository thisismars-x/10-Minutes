
const std = @import("std");

test "std.heap.page_allocator" {

    // asks OS for an entire page of memory
    // more inefficient as it will use several kibibytes
    // even for a single byte
    //

    const allocator = std.heap.page_allocator;
    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory); 

}

test "std.heap.FixedBufferAllocator" {

    //
    // does not allocate to heap
    // useful only when size of buffer is known previously

    var buffer: [100]u8 = undefined;

    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const memory = try allocator.alloc(u8, 100); // <- OutOfMemory error >100
    defer allocator.free(memory);

    try std.testing.expectEqual(@TypeOf(memory), []u8);
}


test "std.heap.ArenaAllocator" {

    // takes in a child allocator
    //              ^ 
    //          lets you init many times and free once
    //  calling deinit frees memory from everywhere @ once
    //

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const memory = try allocator.alloc(u8, 100);
    std.debug.print("{d}\n", .{memory.len});


}

