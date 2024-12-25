
const std = @import("std");
// const cpu_arch = @import("builtin").cpu.arch;

pub fn main() anyerror!void{
    std.debug.print("i am warm", .{});
    // std.debug.print("CPU in use:{}\n", .{cpu_arch});
}

