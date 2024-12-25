
const std = @import("std");

test "comptime and runtime undefined behavior" {
    // 
    // any comptime undefined behavior prevents compilation
    // runtime undefined behavior crashes

    // this code would not compile at all
    // comptime{
    //    unreachable;
    //}
    //
    // this would run and crash at runtime 
    // unreachable; 
    
    // comptime {
    //     const a: [5]u32 = .{1,2,3,4,5};
    //     const b = a[5];
    //     _ = b;
    // }
    //

}

test "truncating bits" {
    comptime {
    const number: u16 = 300;
    const d: u8 = @truncate(number); // implicit conversion would error
    _ = d;
    }
}



pub fn main() void {

    
    
}
