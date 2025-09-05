const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer {
        const gpa_status = gpa.deinit();
        if (gpa_status == .leak) {
            std.testing.expect(false) catch @panic("TEST FAIL");
        }
    }
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);
    if (argv.len != 2) {
        std.debug.print("Invalid number of arguments", .{});
        return;
    }

    if (!std.mem.endsWith(u8, argv[1], ".asm")) {
        std.debug.print("Invalid file name", .{});
        return;
    }

    const file_contents = readFile(allocator, argv[1]) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("Could not open file", .{});
            return;
        },
        else => {
            std.debug.print("An unknown bug occured", .{});
            return;
        },
    };
    defer allocator.free(file_contents);

    var symbol_table = try initSymbolTable(allocator);
    defer symbol_table.deinit();
}

fn initSymbolTable(allocator: std.mem.Allocator) !std.StringHashMap(i16) {
    var hash_map = std.StringHashMap(i16).init(allocator);

    try hash_map.put("R0", 0);
    try hash_map.put("R1", 1);
    try hash_map.put("R2", 2);
    try hash_map.put("R3", 3);
    try hash_map.put("R4", 4);
    try hash_map.put("R5", 5);
    try hash_map.put("R6", 6);
    try hash_map.put("R7", 7);
    try hash_map.put("R8", 8);
    try hash_map.put("R9", 9);
    try hash_map.put("R10", 10);
    try hash_map.put("R11", 11);
    try hash_map.put("R12", 12);
    try hash_map.put("R13", 13);
    try hash_map.put("R14", 14);
    try hash_map.put("R15", 15);
    try hash_map.put("SCREEN", 16384);
    try hash_map.put("KBD", 24576);
    try hash_map.put("SP", 0);
    try hash_map.put("LCL", 1);
    try hash_map.put("ARG", 2);
    try hash_map.put("THIS", 3);
    try hash_map.put("THAT", 4);

    return hash_map;
}

fn readFile(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, 32 * 1024);
    defer allocator.free(buffer);

    var file_reader = file.reader(buffer);
    const file_size = try file_reader.getSize();
    const file_contents = try file_reader.interface.readAlloc(allocator, file_size);
    return file_contents;
}
