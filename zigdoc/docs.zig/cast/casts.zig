const std = @import("std");

test "peer resolving" {

    // this type of resolving occurs in switch,
    // if, else, while
    // where many peers have to agree to 
    // resolve to a common 'type'
    //
    

}
test "explicit casts" {
    
    const x: f32 = 19.12;
    const y: f16 = @floatCast(x);
    
    const ptr: *i32 align(4) = @ptrFromInt(0xdeadbee0);
    //                              ^
    //                      requires int to be well aligned
    //                      0xffffffff would cause misalignment
    //
    const add = @intFromPtr(ptr);
    _ = add;
    std.debug.print("{}\n", .{y});
}


test "type coercion" {

    // if var of type1 is assigned to 
    // var of type2
    //
    // size: type1 < type2
    // eg.
    //

    // const a: u8 = 100;
    // const b: u16 = a;
    //
    // try std.testing.expectEqual(a, b);
    //

    // stricter qualification
    // volatile -> non-volatile
    // bigger align -> smaller align
    // error -> superset
    // ptrs -> optional const ptrs 

    return error.SkipZigTest;
} 

test "implicit coercion to a smaller type" {
    
    const n: u64 = 120; // would fail if n was 'var' instead
    const y: u8 = n;
    
    // if value can be comptime known
    // it can be coerced to smaller type
    
    const a: comptime_float = 100;
    const b: i32 = a;
    _ = b;

    try std.testing.expect(n == y);
}

test "ptrs coerce to const optional ptrs" {

    const mem = [1][*:0]const u8{"hello people"};
    const co_mem: []const ?[*:0]const u8 = &mem;

    try std.testing.expect(std.mem.eql(u8, std.mem.span(co_mem[0].?), "hello people"));

}

test "float integer conversion ambiguity" {
    
    // integer literals are comptime_known
    // 100.0 - comptime_float
    // 11 - comptime_int
    // so either we have to @cast(11, comptime_float)
    // or @cast(100.0, comptime_int)
    
    // const number: f32 = 100.0 / 11;
    // _ = number;

}

test "undefined coercing" {
    var x: i32 = undefined;
    const y: f32 = 100.0;
    x = y; 
}


// tagged unions can coerce to enums

const E = enum {
        one,
        two,
        three,
};

const U = union(E) {
        one: i32,
        two: f32,
        three,
};


