const std = @import("std");
const testing = std.testing;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lines: std.ArrayList([]const u8),
    index: usize,

    const ParserError = error{ IndexOutOfRange, InvalidInstruction, InvalidAInstruction, InvalidCInstruction, InvalidLabelInstruction };

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

        const a_instruction = try parseAInstruction(current_line);
        if (a_instruction) |inst| {
            return Instruction{ .A = inst };
        }

        const label_instruction = try parseLabelInstruction(current_line);
        if (label_instruction) |inst| {
            return Instruction{ .Label = inst };
        }

        const c_instruction = try parseCInstruction(current_line);
        if (c_instruction) |inst| {
            return Instruction{ .C = inst };
        }

        return ParserError.InvalidInstruction;
    }

    fn parseAInstruction(line: []const u8) ParserError!?AInstruction {
        if (std.mem.startsWith(u8, line, "@")) {
            if (line.len <= 1) {
                return ParserError.InvalidAInstruction;
            }

            const a_instruction = AInstruction{ .value = line[1..] };
            return a_instruction;
        }

        return null;
    }

    fn parseCInstruction(line: []const u8) ParserError!?CInstruction {
        const contains_dest: ?usize = std.mem.indexOf(u8, line, "=");
        const contains_jump: ?usize = std.mem.indexOf(u8, line, ";");

        var c_instruction: CInstruction = undefined;
        if (contains_dest) |dest_index| {
            if (dest_index < 1) {
                return ParserError.InvalidCInstruction;
            }

            c_instruction.dest = line[0 .. dest_index - 1];

            if (contains_jump) |jump_index| {
                const dest_greater_jump = (dest_index) > (jump_index);
                const jump_greater_line = (jump_index) >= (line.len - 1);
                const comp_smaller_1 = (jump_index - dest_index) < (1);
                if (dest_greater_jump or jump_greater_line or comp_smaller_1) {
                    return ParserError.InvalidCInstruction;
                }

                c_instruction.jump = line[jump_index + 1 ..];
                c_instruction.comp = line[dest_index + 1 .. jump_index - 1];
            } else {
                const comp_smaller_1 = (line.len - 1 - dest_index) < (1);
                if (comp_smaller_1) {
                    return ParserError.InvalidCInstruction;
                }

                c_instruction.comp = line[dest_index + 1 ..];
            }
        } else if (contains_jump) |jump_index| {
            const jump_is_first_char = (jump_index) < (1);
            const jump_greater_line = (jump_index) >= (line.len - 1);
            if (jump_is_first_char or jump_greater_line) {
                return ParserError.InvalidCInstruction;
            }

            c_instruction.comp = line[0 .. jump_index - 1];
            c_instruction.jump = line[jump_index + 1 ..];
        } else {
            // Line should never be empty
            if ((line.len) < (1)) {
                return ParserError.InvalidCInstruction;
            }

            c_instruction.comp = line;
        }

        return c_instruction;
    }

    fn parseLabelInstruction(line: []const u8) ParserError!?LabelInstruction {
        if (std.mem.startsWith(u8, line, "(") and std.mem.endsWith(u8, line, ")")) {
            if (line.len <= 2) {
                return ParserError.InvalidLabelInstruction;
            }

            const label_instruction = LabelInstruction{ .name = line[1 .. line.len - 2] };
            return label_instruction;
        }

        return null;
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
