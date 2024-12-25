
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

test "tagged union" {

    const a = enum {
        ok,
        not_ok,
    };

    const b = union(a) {
        ok: u8,
        not_ok: u4,
    };

    // switches only work on tagged union
    //

    var c = b{.ok = 100};

    switch (c) {
        .ok => |*v| v.* *= 2,
        .not_ok => print("not ok ok", .{}),
    }

    print("{d}\n", .{c.ok});

}

test "enums in .zig" {

    const value = enum(i32) {
        one,
        two = 20,
        three,
    };

    print("{d}\n", .{@intFromEnum(value.two)});
   // print("{}\n", .{@typeInfo(value).@"enum".tag_type});

}


test "tuples anonymous structs" {

    const n = .{1,2,3, 4,5, '6'-'0'};

    inline for(n) |items| {
        print("{d}\t", .{items});
    }

    print("\n", .{});

}

const maths = struct {
    const PI = 3.14;
};

// functions can return structs
// functions @compile time are memoized
//

fn linkedlist(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };

        first: *?Node,
        last: ?*Node,
        len: usize,
    };
}

test "memoized function calls" {

    try expect(linkedlist(i32) == linkedlist(i32));
   
}


pub fn main() void {
    print("{d}\n", .{@sizeOf(maths)});
}
