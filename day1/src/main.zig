const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

pub fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]i32 {
    var allocator = &arena.allocator;
    var numbers = try std.ArrayList(i32).initCapacity(allocator, 4096);
    while (lines_it.next()) |line| {
        const i = try std.fmt.parseInt(i32, line, 10);
        try numbers.append(i);
    }

    print("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}

pub fn part1(numbers: []i32) i32 {
    var i: usize = 0;
    var num: i32 = 0;
    while (i < numbers.len) : (i += 1) {
        if (i > 0) {
            const prev = numbers[i - 1];
            const curr = numbers[i];
            if (prev < curr) {
                num += 1;
            }
        }
    }
    return num;
}

pub fn part2(numbers: []i32) i32 {
    var num: i32 = 0;
    var prev: i32 = undefined;
    var i: usize = 0;
    const window_size = 3;
    while (i < numbers.len - window_size + 1) : (i += 1) {
        var curr: i32 = 0;
        var w: usize = 0;
        while (w < window_size) : (w += 1) {
            curr += numbers[i + w];
        }
        if (i > 0 and prev < curr) {
            num += 1;
        }
        prev = curr;
    }
    return num;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(input);
    print("Part 1: number of increases: {d}", .{part1_result});

    const part2_result = part2(input);
    print("Part 2: number of increases: {d}", .{part2_result});
}
