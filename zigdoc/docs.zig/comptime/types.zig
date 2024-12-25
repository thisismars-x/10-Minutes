
const std = @import("std");

fn max(comptime T: type, a: T, b: T) T {
    return if(a > b) a else b;
}

test "comptime duck typing" {

    // type bool does not support > operator!
    //
    // this would not run
    // const a = max(bool, true, false);
    // std.debug.print("{}\n", .{a});
    //
    
    return error.SkipZigTest;
}

test "comptime variables" {
    
    // all load and store of comptime var happen during comptime
    comptime var i = 0;
    
    //|-- add inine to comptime var we can write func partially eval at comptime and partially at runtime
    //v
    inline while (i<10) : (i += 1) {
        std.debug.print("{d}\n", .{i});
    }


}
