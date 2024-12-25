
const std = @import("std");

fn print(data: []u8) void{
    std.debug.print("{s}\n", .{data});
}

test "where are the bytes" {
    
    // string literals "abcd" are stored
    // in global const data section
    //
    // const stuff are also stored in global const data sec
    //
    // comptime variables are stored in global cosnt data sec
    // this disqualifies 
    //
    //      print(data: []u8) <- implies a mutable slice
    //      to work when data = "abcd" <- imples imutability
    //      print("abcd") would not work unless 
    //      the params are changed to []const u8
    //
    //      works with data: [5]u8 = "hello";
    //

    print(@constCast("hello people of mars"));
    // @constCast removes const-ness of a ptr
}

// .zig is like C in that its memory is manually managed
// but unlike C .zig provides no default allocator
// to link with libc .zig exposes std.heap.c_allocator
//

