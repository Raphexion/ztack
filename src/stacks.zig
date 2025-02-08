const std = @import("std");
const expect = std.testing.expect;

pub const IntStack = Stack(i32);

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
        };

        allocator: std.mem.Allocator,
        head: ?*Node,
        length: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .head = null,
                .length = 0,
            };
        }

        pub fn push(self: *Self, value: T) !void {
            var node = try self.allocator.create(Node);
            self.length += 1;

            node.value = value;
            node.next = self.head;

            self.head = node;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |head| {
                const value = head.value;
                self.head = head.next;
                self.allocator.destroy(head);
                self.length -= 1;
                return value;
            }

            return null;
        }

        pub fn peek(self: Self) ?T {
            if (self.head) |head| {
                return head.value;
            }

            return null;
        }
    };
}

test "it can create a stack" {
    const allocator = std.heap.page_allocator;
    const stack: IntStack = IntStack.init(allocator);
    try expect(stack.length == 0);

    try expect(stack.peek() == null);
}

test "it is possible to push to the stack" {
    const allocator = std.heap.page_allocator;
    var stack: IntStack = IntStack.init(allocator);

    try stack.push(11);
    try expect(stack.length == 1);
    try expect(stack.peek() == 11);

    try stack.push(22);
    try expect(stack.length == 2);
    try expect(stack.peek() == 22);

    try stack.push(33);
    try expect(stack.length == 3);
    try expect(stack.peek() == 33);
}

test "it is possible to pop to the stack" {
    const allocator = std.heap.page_allocator;
    var stack: IntStack = IntStack.init(allocator);

    try stack.push(11);
    try expect(stack.length == 1);

    const peek = stack.peek() orelse null;
    try expect(peek == 11);

    _ = stack.pop();
    try expect(stack.length == 0);

    _ = stack.pop();
    try expect(stack.length == 0);
}
