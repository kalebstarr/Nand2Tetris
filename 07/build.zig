const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const required = std.SemanticVersion.parse("0.15.1") catch unreachable;
    if (std.SemanticVersion.order(builtin.zig_version, required) != .eq) {
        @panic("This project requires Zig 0.15.1");
    }

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "VMTranslator", .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    }) });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the VM Translator");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // --- Tests ---

    const tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    }) });

    const test_step = b.step("test", "Run tests");
    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);
}
