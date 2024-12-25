
const std = @import("std");
const expect = std.testing.expect;

const mem = std.mem;

test "are slices funny?" {

    // slices are ptr + length(known at runtime)
    // if length of slice is known at comptime
    // it can be casted to a ptr
    //  

    const arr1 = [_]i32 {1,2,3,4,5,6,7,8,9};
    var offset: usize = 0;
    offset += 1;
    // 'var' != comptime known

    const slice = arr1[offset..];
   
    slice.len = 2; 
    try std.testing.expectEqual(
        @intFromPtr(slice.ptr),
        @intFromPtr(&slice[0])
    );
    try std.testing.expectEqualSlices(i32, slice, &[_]i32{2,3,4,5,6,7,8,9});

}

test "sentinel terminated arrays" {
    const arr = [_:10] u8{1,2,3,4};
    std.debug.print("{}: {}\n", .{arr[4], @TypeOf(arr)});
}


test "arrays" {

    const msg = [_]u8{'h', 'e', 'l', 'l', 'o'};
    const msg_ = "hello"; 
    //     ^
    //     i
    //     i-- msg_ is a single item ptr to array
    //

    std.debug.assert(mem.eql(u8, &msg, msg_));

    var random: [100]i32 = undefined;

    for (&random, 0..) |*item, i| {
       item.* = @intCast(i);
    }

   for (random) |item| std.debug.print("{}\t", .{item});

   // std.debug.print("{}\n", random[101]); is an error 

}

// array concatenation works only if values are
// known at comptime
//

const n1 : [2]i32 = .{1,2};
const n2: [3]i32 = .{3,4,5};
const n3: [5]i32 = n1 ++ n2;

comptime {
    std.debug.assert(mem.eql(i32, &n3, &[_]i32{1,2,3,4,5}));
}


test "SIMD operations on .zig vectors" {

    // SIMD instructions smaller than target machine's native SIMD
    // size will cause a single SIMD instr, 
    // else many will run parallely
    //

    const a = @Vector(4, i32) {1,2,3,4};
    const b: @Vector(4, i32) = .{1,2,3,4};
    
    // what is a vector? collections of
    // int, float, bool or ptr
    // which operate with SIMD instr
    //
    const c = a + b;
    std.debug.print("{}\n", .{c[0]});
}

test "conversion vector array slices" {
    
    const a = [_]i32 {1,2};
    const b: @Vector(2, i32) = a;
    // _ = b; // <- vector and array are interconvertible as expected
           //
    const c: [2]i32 = b;
    _ = c;

    const x: @Vector(1, i32) = a[1..].*;
    _ = x;
}
