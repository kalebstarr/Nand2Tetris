const std = @import("std");

pub const SymbolTable = struct {
    allocator: std.mem.Allocator,
    table: std.StringHashMap(u16),
    new_symbol_index: u16,

    pub fn init(allocator: std.mem.Allocator) !SymbolTable {
        return SymbolTable{ .allocator = allocator, .table = try initSymbolTable(allocator), .new_symbol_index = 16 };
    }

    pub fn deinit(self: *SymbolTable) void {
        self.table.deinit();
    }

    fn initSymbolTable(allocator: std.mem.Allocator) !std.StringHashMap(u16) {
        var table = std.StringHashMap(u16).init(allocator);

        try table.put("R0", 0);
        try table.put("R1", 1);
        try table.put("R2", 2);
        try table.put("R3", 3);
        try table.put("R4", 4);
        try table.put("R5", 5);
        try table.put("R6", 6);
        try table.put("R7", 7);
        try table.put("R8", 8);
        try table.put("R9", 9);
        try table.put("R10", 10);
        try table.put("R11", 11);
        try table.put("R12", 12);
        try table.put("R13", 13);
        try table.put("R14", 14);
        try table.put("R15", 15);
        try table.put("SCREEN", 16384);
        try table.put("KBD", 24576);
        try table.put("SP", 0);
        try table.put("LCL", 1);
        try table.put("ARG", 2);
        try table.put("THIS", 3);
        try table.put("THAT", 4);

        return table;
    }
};
