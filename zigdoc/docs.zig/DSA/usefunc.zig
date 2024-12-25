
const std = @import("std");

extern fn arch() void;


const pid = struct {
    p: i32,
    id: i64,
};

fn change(x: *pid) void {
    // for a func that does not demand pointer access
    // eg if xyz() asked for x: pid
    // the compiler could chose to pass by ref or by value
    // this is in part because params are immutable
    // by default, nice!
    //
    x.p = 0;
}


inline fn xyz(b: i32) void {
    // if a func can not be inlined
    // it is a compile error
    //
    var a: i32 = 1;
    a += b;
    std.debug.print("{d}\n", .{a});
}

inline fn alloc(size: usize) anyerror![]u8 {
    //^
    //i
    //i__ inline is not a hint but a strict requirement
    //      which can harm bin size, comp speeds
    xyz(10);

    const pg = std.heap.page_allocator;
    
    return pg.alloc(u8, size);
    

}
fn abort() noreturn {
       // @branchHint("cold"); supposed to tell compiler this func
       // is rarely used. did not work 
        
        while (true) {}
}
pub fn main() anyerror!void{
    arch();
    var x: i32 = 100;
    
    if(@TypeOf(arch) == void){
        x += 100;
    }else {
        x += 200;
    }

    xyz(x);
    // abort();
    
    var a: i32 = 100; a += 100;

    const ptr = try alloc(@intCast(a));
    _ = ptr;

    var id: pid = .{ .p = 100, .id = 200};
    change(&id);

    std.debug.print("{d}\n", .{id.p});


}


