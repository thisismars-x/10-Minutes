const std = @import("std");

// types that can have only one possible values
// void, i0, f0, Vector with zero bit types
// struct with zero bit types
//

const x = struct {
    const n: i32 = 100;
};

test "0 bit types" {
    std.debug.print("{}\n", .{@sizeOf(x)});
}
