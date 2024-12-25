
const print = std.debug.print;
const std = @import("std");
const builtin = std.builtin;

var adress_buffer: [8]usize = undefined;

// .zig supports the same stack and error return traces
// on all targets even freestanding

var trace1 = builtin.StackTrace {
    .instruction_addresses = adress_buffer[0..4],
    .index = 0,
};

var trace2 = builtin.StackTrace {
    .instruction_addresses = adress_buffer[4..],
    .index = 0,
};


fn foo() void {
    std.debug.captureStackTrace(null, &trace1);
}

fn bar() void {
    std.debug.captureStackTrace(null, &trace2);
}

pub fn main() void {
    
    foo();
    bar();

    print("First:\n", .{});
    std.debug.dumpStackTrace(trace1);
    print("Second:\n", .{});
    std.debug.dumpStackTrace(trace2);

}

















