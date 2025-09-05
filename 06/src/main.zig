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
    // TODO: Improve error output message
    std.debug.assert(argv.len == 2);

    const file = try std.fs.cwd().openFile(argv[1], .{});
    defer file.close();
    const buffer = try allocator.alloc(u8, 32 * 1024);
    defer allocator.free(buffer);
    var file_reader = file.reader(buffer);
    const file_size = try file_reader.getSize();

    const file_contents = try file_reader.interface.readAlloc(allocator, file_size);
    defer allocator.free(file_contents);
}
