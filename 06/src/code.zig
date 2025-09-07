const std = @import("std");

pub const Code = struct {
    allocator: std.mem.Allocator,
    dest_table: std.StringHashMap([]const u8),
    comp_table: std.StringHashMap([]const u8),
    jump_table: std.StringHashMap([]const u8),

    pub fn init(allocator: std.mem.Allocator) !Code {
        return Code{ .allocator = allocator, .dest_table = try initDestTable(allocator), .comp_table = try initCompTable(allocator), .jump_table = try initJumpTable(allocator) };
    }

    pub fn deinit(self: *Code) void {
        self.dest_table.deinit();
        self.comp_table.deinit();
        self.jump_table.deinit();
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

    fn initCompTable(allocator: std.mem.Allocator) !std.StringHashMap([]const u8) {
        var comp_table = std.StringHashMap([]const u8).init(allocator);

        // a == 0
        try comp_table.put("0", "0101010");
        try comp_table.put("1", "0111111");
        try comp_table.put("-1", "0111010");
        try comp_table.put("D", "0001100");
        try comp_table.put("A", "0110000");
        try comp_table.put("!D", "0001101");
        try comp_table.put("!A", "0110001");
        try comp_table.put("-D", "0001111");
        try comp_table.put("-A", "0110011");
        try comp_table.put("D+1", "0011111");
        try comp_table.put("A+1", "0110111");
        try comp_table.put("D-1", "0001110");
        try comp_table.put("A-1", "0110010");
        try comp_table.put("D+A", "0000010");
        try comp_table.put("D-A", "0010011");
        try comp_table.put("A-D", "0000111");
        try comp_table.put("D&A", "0000000");
        try comp_table.put("D|A", "0010101");

        // a == 1
        try comp_table.put("M", "1110000");
        try comp_table.put("!M", "1110001");
        try comp_table.put("-M", "1110011");
        try comp_table.put("M+1", "1110111");
        try comp_table.put("M-1", "1110010");
        try comp_table.put("D+M", "1000010");
        try comp_table.put("D-M", "1010011");
        try comp_table.put("M-D", "1000111");
        try comp_table.put("D&M", "1000000");
        try comp_table.put("D|M", "1010101");

        return comp_table;
    }

    fn initJumpTable(allocator: std.mem.Allocator) !std.StringHashMap([]const u8) {
        var jump_table = std.StringHashMap([]const u8).init(allocator);

        try jump_table.put("null", "000");
        try jump_table.put("JGT", "001");
        try jump_table.put("JEQ", "010");
        try jump_table.put("JGE", "011");
        try jump_table.put("JLT", "100");
        try jump_table.put("JNE", "101");
        try jump_table.put("JLE", "110");
        try jump_table.put("JMP", "111");

        return jump_table;
    }
};
