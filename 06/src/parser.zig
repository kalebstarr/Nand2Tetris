const std = @import("std");

pub fn hasMoreLines(lines: std.ArrayList([]u8), current_line_index: usize) bool {
    if (current_line_index < lines.items.len) {
        return true;
    }
    return false;
}
