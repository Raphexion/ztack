// Inspired by Zig Master: Let's Create a Trie!
// by Dude the Builder

const std = @import("std");
const mem = std.mem;
const expect = std.testing.expect;

const NodeMap = std.AutoHashMap(u8, Node);

const Node = struct {
    const Self = @This();

    terminal: bool = false,
    children: NodeMap,

    fn init(allocator: mem.Allocator) Self {
        return .{ .children = NodeMap.init(allocator) };
    }

    fn deinit(self: *Self) void {
        var iter = self.children.valueIterator();
        while (iter.next()) |node| node.deinit();
        self.children.deinit();
    }
};

const Trie = struct {
    const Self = @This();

    allocator: mem.Allocator,
    root: Node,

    fn init(allocator: mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .root = Node.init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self.root.deinit();
    }

    fn insert(self: *Self, str: []const u8) !void {
        var node = &self.root;

        for (str, 0..) |ch, ii| {
            var gop = try node.children.getOrPut(ch);

            if (!gop.found_existing) {
                gop.value_ptr.* = Node.init(self.allocator);
            }

            const terminal = (ii + 1) == str.len;
            gop.value_ptr.terminal = terminal;

            node = gop.value_ptr;
        }
    }

    fn lookup(self: Self, str: []const u8) bool {
        var node = self.root;

        for (str, 0..) |ch, ii| {
            if (node.children.get(ch)) |found| {
                const terminal = (ii + 1) == str.len;
                if (terminal and found.terminal) return true;
                node = found;
            } else {
                break;
            }
        }

        return false;
    }
};

const monkeyKeywords = [_][]const u8{
    "fn",
    "let",
    "true",
    "false",
    "if",
    "else",
    "return",
};

const randomNames = [_][]const u8{
    "Alice",
    "Bob",
    "Charlie",
    "Diana",
    "Eve",
    "Frank",
    "Grace",
    "Heidi",
    "Ivan",
    "Judy",
    "Mallory",
    "Trent",
};

test "it finds the strings we insert" {
    const allocator = std.testing.allocator;
    var trie = Trie.init(allocator);

    for (monkeyKeywords) |keyword| {
        try trie.insert(keyword);
    }

    for (monkeyKeywords) |keyword| {
        try expect(trie.lookup(keyword));
    }

    for (randomNames) |name| {
        try expect(!trie.lookup(name));
    }

    trie.deinit();
}
