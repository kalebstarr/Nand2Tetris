const std = @import("std");
const testing = std.testing;

const ParserError = error{IndexOutOfRange};

pub fn hasMoreLines(lines: std.ArrayList([]u8), current_line_index: usize) bool {
    if (current_line_index < lines.items.len) {
        return true;
    }
    return false;
}

pub fn advance(lines: std.ArrayList([]u8), current_line_index: *usize) ParserError![]u8 {
    if (current_line_index.* >= lines.items.len - 1) {
        return ParserError.IndexOutOfRange;
    }

    current_line_index.* += 1;
    return lines.items[current_line_index.*];
}

test "advance increments current_line_index" {
    const allocator = testing.allocator;

    var list = std.ArrayList([]u8).empty;
    defer {
        for (list.items) |value| {
            allocator.free(value);
        }
        list.deinit(allocator);
    }

    try list.append(allocator, try allocator.dupe(u8, "One"));
    try list.append(allocator, try allocator.dupe(u8, "Two"));
    try list.append(allocator, try allocator.dupe(u8, "Three"));

    var current_line_index: usize = 0;
    const two = try advance(list, &current_line_index);
    const three = try advance(list, &current_line_index);

    try testing.expectEqualStrings(two, "Two");
    try testing.expectEqualStrings(three, "Three");
}

test "advance returns OutOfBounds error" {
    const allocator = testing.allocator;

    var list = std.ArrayList([]u8).empty;
    defer {
        for (list.items) |value| {
            allocator.free(value);
        }
        list.deinit(allocator);
    }

    try list.append(allocator, try allocator.dupe(u8, "One"));

    var current_line_index: usize = 0;

    try testing.expectError(ParserError.IndexOutOfRange, advance(list, &current_line_index));
}
