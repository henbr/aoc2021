const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

const Instruction = union(enum) { Forward: i32, Down: i32, Up: i32 };

pub fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]Instruction {
    var allocator = &arena.allocator;
    var numbers = try std.ArrayList(Instruction).initCapacity(allocator, 4096);
    while (lines_it.next()) |line| {
        var line_it = std.mem.split(u8, line, " ");
        const dir = line_it.next() orelse unreachable;
        const dist = line_it.next() orelse unreachable;
        const dist_num = try std.fmt.parseInt(i32, dist, 10);
        const inst = if (std.mem.eql(u8, dir, "forward"))
            Instruction{ .Forward = dist_num }
        else if (std.mem.eql(u8, dir, "down"))
            Instruction{ .Down = dist_num }
        else if (std.mem.eql(u8, dir, "up"))
            Instruction{ .Up = dist_num }
        else
            unreachable;
        try numbers.append(inst);
    }

    print("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}

pub fn part1(instructions: []Instruction) i32 {
    var i: usize = 0;
    var horizontal: i32 = 0;
    var depth: i32 = 0;
    while (i < instructions.len) : (i += 1) {
        switch (instructions[i]) {
            .Forward => |dist| {
                horizontal += dist;
            },
            .Down => |dist| {
                depth += dist;
            },
            .Up => |dist| {
                depth -= dist;
            },
        }
    }
    return horizontal * depth;
}

pub fn part2(instructions: []Instruction) i64 {
    var i: usize = 0;
    var horizontal: i64 = 0;
    var depth: i64 = 0;
    var aim: i64 = 0;
    while (i < instructions.len) : (i += 1) {
        switch (instructions[i]) {
            .Forward => |dist| {
                horizontal += dist;
                depth += aim * dist;
            },
            .Down => |dist| {
                aim += dist;
            },
            .Up => |dist| {
                aim -= dist;
            },
        }
    }
    return horizontal * depth;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(input);
    print("Part 1: {d}", .{part1_result});

    const part2_result = part2(input);
    print("Part 2: {d}", .{part2_result});
}
