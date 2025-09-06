const std = @import("std");
const testing = std.testing;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lines: std.ArrayList([]const u8),
    index: usize,

    const ParserError = error{IndexOutOfRange, InvalidAInstruction, InvalidCInstruction};

    pub fn init(allocator: std.mem.Allocator) Parser {
        return .{ .allocator = allocator, .lines = std.ArrayList([]const u8).empty, .index = 0 };
    }

    pub fn initFromLines(allocator: std.mem.Allocator, lines: std.ArrayList([]const u8)) Parser {
        return .{ .allocator = allocator, .lines = lines, .index = 0 };
    }

    pub fn deinit(self: *Parser) void {
        for (self.lines.items) |value| {
            self.allocator.free(value);
        }
        self.lines.deinit(self.allocator);
    }

    pub fn hasMoreLines(self: *Parser) bool {
        if (self.index < self.lines.items.len) {
            return true;
        }
        return false;
    }

    pub fn advance(self: *Parser) ParserError![]u8 {
        if (self.index >= self.lines.items.len - 1) {
            return ParserError.IndexOutOfRange;
        }

        self.index += 1;
        return self.lines.items[self.index];
    }

    pub const Instruction = union(enum) {
        A: AInstruction,
        C: CInstruction,
        Label: LabelInstruction,
    };

    pub const AInstruction = struct {
        value: []const u8,
    };

    pub const CInstruction = struct {
        dest: ?[]const u8,
        comp: []const u8,
        jump: ?[]const u8,
    };

    pub const LabelInstruction = struct {
        name: []const u8,
    };

    pub fn instructionType(self: *Parser) ParserError!Instruction {
        const current_line = self.lines.items[self.index];
        if (std.mem.startsWith(u8, current_line, "@")) {
            if (current_line.len <= 1) {
                return ParserError.InvalidAInstruction;
            }

            const a_instruction = AInstruction{.value = current_line[1..]};
            return Instruction{.A = a_instruction};
        }

        // TODO: Implement parsing for C and Label Instructions
        return ParserError.InvalidCInstruction;
    }
};

test "advance increments current_line_index" {
    const allocator = testing.allocator;

    var parser = Parser.init(allocator);
    defer parser.deinit();

    try parser.lines.append(allocator, try allocator.dupe(u8, "One"));
    try parser.lines.append(allocator, try allocator.dupe(u8, "Two"));
    try parser.lines.append(allocator, try allocator.dupe(u8, "Three"));

    const two = try parser.advance();
    const three = try parser.advance();

    try testing.expectEqualStrings(two, "Two");
    try testing.expectEqualStrings(three, "Three");
}

test "advance returns OutOfBounds error" {
    const allocator = testing.allocator;

    var parser = Parser.init(allocator);
    defer parser.deinit();

    try parser.lines.append(allocator, try allocator.dupe(u8, "One"));

    try testing.expectError(Parser.ParserError.IndexOutOfRange, parser.advance());
}
