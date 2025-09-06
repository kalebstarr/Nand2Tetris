const std = @import("std");

pub fn hasMoreLines(lines: std.ArrayList([]u8), current_line_number: usize) bool {
    if (current_line_number < lines.items.len) {
        return true;
    }
    return false;
}
