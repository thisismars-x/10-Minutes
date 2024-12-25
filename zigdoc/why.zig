//! explore the caveats to C
//! https://ziglang.org/learn/overview/

const network = struct {
    internet: []const u8,
    status: bool,
    access: u8,
    msg: []const u8,
};

test "control flow" {
    
    // hidden control flow obscures away too much 
    // implementation details
    //
    // In C++, Rust, I can never be sure what + operator 
    // does. 
    //
    // In other languages(Go)
    //
    //         foo();
    //         bar(); 
    //          ^
    // bar(); may never be called if foo throws an exception
    // this can not occur in .zig
    //
     return error.SkipZigTest;

}

test "integer overflow" {

   // var x: u8 = 255;
   // x += 1;
   //
   // to disable runtime safety checks 
   // i could do 
   //

   @setRuntimeSafety(false);
   var x: u8 = 255;
   x += 1; // this test passes
           // disabling runtime safety can STILL CAUSE 
           // UNDEFINED BEHAVIOR(?) in .zig
           // only for performance bottleneck parts

}

test "optional with easier syntax" {

    const ptr: ?*i32 = @ptrFromInt(0x0);
    
    print("{d}", .{ptr orelse 0});

}

test "manual memory management" {

    // .zig standard library is efficient even on 
    // bare metal, because anywhere memory needs to be
    // manually allocated, deallocated 
    // an allocator is required(different allocator
    // allocate for different needs)
    //
    // defer and errdefer are nice
    //
    


}

test "types and generics" {


    //
    // types are comptime known values
    // the 'type' of type is 'type'
    // which means this should run  
    
    const x = u8;
    const y = u8;

    std.debug.assert(x == y);

    // generic data structures are functions
    // that return a type
    //
    // fn List(comptime T: type) type {
    //      return struct {
    //          items: []T,
    //          len: usize,
    //      };
    //  }
    //
    //  as long as the 'type' is comptime known
    //  there should be no overhead in using generic 
    //  data structures
}

test "type reflection" {

    // @typeInfo of structs, unions, enums, and error sets
    // are guaranteed to be in the same order
    // as that in src file
    //
    
    const info = @typeInfo(network);
    
    print("\n", .{}); 
    inline for (info.Struct.fields) |field| {
        print(
            "{s} has field named {s} with type {s}\n",
            .{ @typeName(network), field.name, @typeName(field.type) }
        );
    }
}



pub fn main() anyerror!void {

}

//
// top level declarations are lazily evaluated(order independent also)
// writing:
//      const number = 100;
//
// is a compile time error if number is never used
// but const std = @import("std")
// is not an error even if never used because it is lazily evaluated
// (this is nice)

const std = @import("std");
const print = std.debug.print;

