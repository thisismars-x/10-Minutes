
const print = std.debug.print;
const fs = std.fs;
const std = @import("std");

pub fn main() @TypeOf({}) {
    
    print("MAX_NAME_SIZE(in bytes 'u8'): {d}\n", .{fs.MAX_NAME_BYTES});    

}
