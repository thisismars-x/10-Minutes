
const std = @import("std");
const builtin = @import("builtin").cpu.arch;

pub fn main() void {
    std.debug.print("{}\n", .{builtin});
}
