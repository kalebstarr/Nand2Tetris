const std = @import("std");
const testing = std.testing;
const Parser = @import("parser.zig").Parser;
const Code = @import("code.zig").Code;
const SymbolTable = @import("symbol_table.zig").SymbolTable;

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

    const lines = readFile(allocator, argv[1]) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("Could not open file", .{});
            return;
        },
        else => {
            std.debug.print("An unknown bug occured", .{});
            return;
        },
    };

    var parser = Parser.initFromLines(allocator, lines);
    defer parser.deinit();

    _ = try parser.instructionType();
    _ = try parser.jump();

    var code = try Code.init(allocator);
    defer code.deinit();

    var symbol_table = try SymbolTable.init(allocator);
    defer symbol_table.deinit();
}

fn readFile(allocator: std.mem.Allocator, file_name: []const u8) !std.ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, 32 * 1024);
    defer allocator.free(buffer);

    var list = std.ArrayList([]const u8).empty;
    var file_reader = file.reader(buffer);

    while (true) {
        const line = file_reader.interface.takeDelimiterExclusive('\n') catch |err| {
            switch (err) {
                error.EndOfStream => {
                    break;
                },
                else => {
                    break;
                },
            }
        };

        const cleaned_line = cleanLine(line);
        switch (cleaned_line) {
            .is_comment_or_empty => continue,
            .text => |in| try list.append(allocator, try allocator.dupe(u8, in)),
        }
    }

    return list;
}

const cleanLineResult = union(enum) {
    text: []const u8,
    is_comment_or_empty: bool,
};

fn cleanLine(line: []const u8) cleanLineResult {
    const trimmed = std.mem.trim(u8, line, " \t\n\r");

    if (std.mem.startsWith(u8, trimmed, "//") or trimmed.len == 0) {
        return cleanLineResult{ .is_comment_or_empty = true };
    }
    const comment_removed = if (std.mem.indexOf(u8, trimmed, "//")) |pos|
        std.mem.trim(u8, trimmed[0..pos], " \t")
    else
        trimmed;

    return cleanLineResult{ .text = comment_removed };
}

test "cleanLine skips comment- and empty lines" {
    const expected = cleanLineResult{ .is_comment_or_empty = true };
    const comment = "// One, Two, Three";
    const empty_string = "";

    const cleaned_comment = cleanLine(comment);
    const cleaned_empty = cleanLine(empty_string);

    try testing.expectEqual(expected, cleaned_comment);
    try testing.expectEqual(expected, cleaned_empty);
}

test "cleanLine removes comment from end of line" {
    const expected = cleanLineResult{ .text = "One, Two, Three" };
    const comment = "One, Two, Three // Comment";
    const no_comment = "  One, Two, Three ";

    const cleaned_comment = cleanLine(comment);
    const cleaned_no_comment = cleanLine(no_comment);

    try testing.expectEqualStrings(expected.text, cleaned_comment.text);
    try testing.expectEqualStrings(expected.text, cleaned_no_comment.text);
}
