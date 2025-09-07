const std = @import("std");

pub const Code = struct {
    allocator: std.mem.Allocator,
    dest_table: std.StringHashMap([]const u8),

    pub fn init(allocator: std.mem.Allocator) !Code {
        return Code{ .allocator = allocator, .dest_table = try initDestTable(allocator) };
    }

    pub fn deinit(self: *Code) void {
        self.dest_table.deinit();
    }

    fn initDestTable(allocator: std.mem.Allocator) !std.StringHashMap([]const u8) {
        var dest_table = std.StringHashMap([]const u8).init(allocator);

        try dest_table.put("null", "000");
        try dest_table.put("M", "001");
        try dest_table.put("D", "010");
        try dest_table.put("DM", "011");
        try dest_table.put("A", "100");
        try dest_table.put("AM", "101");
        try dest_table.put("AD", "110");
        try dest_table.put("ADM", "111");

        return dest_table;
    }
};
