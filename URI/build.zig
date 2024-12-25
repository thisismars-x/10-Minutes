const std = @import("std");
const builder = std.Build;

// build file for test
// run zig build test --summary all
pub fn build(b: *builder) void {

    const test_step = b.step("test", "running library tests");

    const tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),

    });

    const run_tests = b.addRunArtifact(tests);

    test_step.dependOn(&run_tests.step);
}
