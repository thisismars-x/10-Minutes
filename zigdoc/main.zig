
const std = @import("std");

pub fn main() void {
    std.debug.print("this need not be {}\n", .{true});
}
