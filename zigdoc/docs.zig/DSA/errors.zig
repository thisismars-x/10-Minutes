
const std = @import("std");

const err1 = error {
        file_dynamic,
        handler_corrupt,
};

 const err2 = error {
        file_dynamic,
};

test "error coerce subset -> superset only" {
   
    // error are typically u16 enums
    // errors across compilation are assigned different numbers
    // if two error set have same error they have the same number
    //
   
    xyz(err2.file_dynamic) catch {};

}

fn abc(t: type) !bool {

    return switch(t) {
        bool => true,
        i32 => false,
        *i32 => error.PointerInvalidated,
        else => error.OtherTypes,
    };
}


test "error unions" {

    // !T, either an error or type T
    //

    const v = abc(*i32) catch false; // catch x: T;
    std.debug.print("{}\n", .{v});

    // try: catch |err| return err;
    // try returns from fn as soon as error is encountered
    //

  //  const p = try abc(*i32); _ = p;
    
  // errdefer std.debug.print("welcome error" , .{});
  //
    
    const merge_s = err1 || err2;
    _ = merge_s;
}

fn def(i: i32) ?i32 {

    if(i == 0) return 100 else return null;
}


test "optional types" {
    const a = def(100) orelse 2;
    _ = a;
    

}

fn xyz(x: err2)  err1 {
       return x;
}
