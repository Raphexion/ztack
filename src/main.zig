const std = @import("std");
const stacks = @import("stacks.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var stack = stacks.IntStack.init(allocator);

    try stack.push(42);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Stack has size {}\n", .{stack.length});
}
