const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]i32 {
    var numbers = try std.ArrayList(i32).initCapacity(&arena.allocator, 4096);
    while (lines_it.next()) |line| {
        const i = try std.fmt.parseInt(i32, line, 10);
        try numbers.append(i);
    }

    print("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}

fn part1(_: []i32) i32 {
    return 0;
}

fn part2(_: []i32) i32 {
    return 0;
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
