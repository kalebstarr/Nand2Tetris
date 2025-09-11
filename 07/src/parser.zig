const std = @import("std");
const testing = std.testing;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lines: std.ArrayList([]const u8),
    index: usize,

    const ParserError = error{ IndexOutOfRange, InvalidCommand };

    pub fn init(allocator: std.mem.Allocator) Parser {
        return .{ .allocator = allocator, .lines = std.ArrayList([]const u8).empty, .index = 0 };
    }

    pub fn deinit(self: *Parser) void {
        for (self.lines.items) |value| {
            self.allocator.free(value);
        }
        self.lines.deinit(self.allocator);
    }

    pub fn readFile(self: *Parser, file_name: []const u8) !void {
        const file = try std.fs.cwd().openFile(file_name, .{});
        defer file.close();

        var buffer: [2048]u8 = undefined;

        var file_reader = file.reader(&buffer);

        while (true) {
            const line = file_reader.interface.takeDelimiterExclusive('\n') catch |err| {
                switch (err) {
                    else => {
                        break;
                    },
                }
            };

            const cleaned_line = cleanLine(line);
            switch (cleaned_line) {
                .skip => continue,
                .text => |in| try self.lines.append(self.allocator, try self.allocator.dupe(u8, in)),
            }
        }
    }

    const cleanLineResult = union(enum) {
        text: []const u8,
        skip: bool,
    };

    fn cleanLine(line: []const u8) cleanLineResult {
        const trimmed = std.mem.trim(u8, line, " \t\n\r");

        if (std.mem.startsWith(u8, trimmed, "//") or trimmed.len == 0) {
            return cleanLineResult{ .skip = true };
        }
        const comment_removed = if (std.mem.indexOf(u8, trimmed, "//")) |pos|
            std.mem.trim(u8, trimmed[0..pos], " \t")
        else
            trimmed;

        return cleanLineResult{ .text = comment_removed };
    }

    pub fn hasMoreLines(self: *Parser) bool {
        if (self.index < self.lines.items.len) {
            return true;
        }
        return false;
    }

    pub fn advance(self: *Parser) ParserError!void {
        if (self.index >= self.lines.items.len) {
            return ParserError.IndexOutOfRange;
        }

        self.index += 1;
    }

    pub fn reset(self: *Parser) void {
        self.index = 0;
    }
};
