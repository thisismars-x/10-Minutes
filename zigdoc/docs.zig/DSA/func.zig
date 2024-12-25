
 const std = @import("std"); 
const cpu_arch = @import("builtin").cpu.arch;

// export makes function visible in generated
// object file following C ABI
// it must be compatible with C?
//

pub export fn arch() void{

    std.debug.print("{}\n", .{cpu_arch});
}
