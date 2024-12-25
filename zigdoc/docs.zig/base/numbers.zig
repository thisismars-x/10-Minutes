
const std = @import("std");

test "weird identifiers" {
    const @"this is a name" = 20;

    try std.testing.expect(@"this is a name" == 20);
}

test {
    // unnamed tests
    // 
}

test "runtime types" {

    // numeric literals are comptime_int|float by default
    //
    // const c: f32 = 100_00.012
    // is an implicit coercion from comptime_float to f32

    var u: u8 = 255;
    u = u +% 255;
    
    std.debug.print("{d}\n", .{u});

    u = u +| 255;
    std.debug.print("{d}\n", .{u});

}
