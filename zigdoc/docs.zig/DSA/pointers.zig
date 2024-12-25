
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

fn deref(ptr : *const align(2) i32) void {
    print("{d}\n", .{ptr.*});
}


test "pointer alignment" {

    // alignment coecrcion goes from
    // bigger --> smaller
    //

    const number: i32 = 100;
    var ptr  = &number;
    _ = &ptr;

    deref(ptr); // <-- asks for align(2) receives align(8)
                // implicitly coerces

    //print("{d}\n", .{@typeInfo(*i32).pointer.alignment});
    print("{d}\n", .{@alignOf(@TypeOf(ptr))});
}


test "comptime pointers" {
    
    //var mem: i32 = 100;
    //const add = &mem; 
    
    // .zig can preserve memories 
    // in comptime code only if mem is
    // never dereferenced(check for valid address)
    //
    const ptr: *i32 = @ptrFromInt(0xdeadbee0);
    // print("{}\n", .{ptr.*}); <-- Error

    const int = @intFromPtr(ptr);
    print("0x{x}\n",. {int});

}


test "slices are better than (sentinel terminated)pointers" {

    const arr: [5]i32 = .{0, 1, 2, 3, 4, };
    var m_ptr: [*]const i32 = &arr;
    
    print("{d}\n", .{m_ptr[0]});
    try expect(@TypeOf(m_ptr) == [*]const i32);
        
    // after assigning to a many item pointer [*]T
    // incr it is totally valid
    // not only is it valid
    // doing:   m_ptr += 1
    // gives:   1
    // instead: 0
    //
    // but there is no bound checking on a many item pointer and
    // we may still access m_ptr[4] although
    // we incr m_ptr by 1 so 4th index should not be valid 
    // not only can we access index 4, but even 40
    //
    m_ptr += 1;
    print("{d}\n", .{m_ptr[4]}); 

    var slice: []const i32 = &arr;
    print("{d}\n", .{slice[0]});

    slice.ptr += 1; // this puts slice in a bad state
                    // because .len is const 
                    // we can access [4] but not [5]
                    // unlike simple multiitem ptrs
                    //
                    // slices are fat ptrs(multi item ptrs + length)
    print("{d}\n", .{slice[4]});
}


test "single item pointer to an array" {

    var arr: [5]i32 = .{1,2,3,4,5};
    const ptr = &arr;
    
    std.debug.print("{d}: {}\n", .{ptr.*, @TypeOf(ptr)});
    //                                             ^
    //                                             i  
    // for anytype T, a single item pointer        i 
    // is *T    ------------------------------------
    //

    var number: i32 = 100;
    const ptr_ = &number; 

    try std.testing.expect(@TypeOf(ptr_) == *i32);
    ptr_.* += 200;
 
    std.debug.print("{d}\n", .{ptr_.*});
    

}
