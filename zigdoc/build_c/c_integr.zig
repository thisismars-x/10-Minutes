
//! exploring "Zig is better at using C libraries than C is at using C libraries."
//!

const std = @import("std");
const c = @cImport({ @cInclude("stdio.h"); });
// no FFI?
// Yes, no FFI

const f = @cImport({ @cInclude("file.c"); });

pub fn main() !void {
    
    f.printer();

    // .zig types are automatically C-compatible unlike Rust
    //

    f.print_string("hello");
    const a = c.printf("calling C directly from .zig\n");

    std.debug.print("{d}", .{a});
}




