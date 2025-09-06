const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "assembler", .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    }) });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the assembler");
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

    const parser_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("src/parser.zig"),
        .target = target,
        .optimize = optimize,
    }) });

    const parser_test_step = b.step("test-parser", "Run tests");
    const parser_run_tests = b.addRunArtifact(parser_tests);
    parser_test_step.dependOn(&parser_run_tests.step);
}
