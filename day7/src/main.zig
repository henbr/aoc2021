const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]i32 {
    var numbers = try std.ArrayList(i32).initCapacity(&arena.allocator, 4096);
    var line = lines_it.next().?;
    var num_it = std.mem.tokenize(u8, line, ",");
    while (num_it.next()) |num| {
        const i = try std.fmt.parseInt(i32, num, 10);
        try numbers.append(i);
    }

    print("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}

fn part1(arena: *ArenaAllocator, positions: []i32) anyerror!i32 {
    var max: i32 = positions[0];
    for (positions) |position| {
        max = std.math.max(max, position);
    }

    var count_by_position = try arena.allocator.alloc(i32, @intCast(usize, max + 1));
    std.mem.set(i32, count_by_position, 0);
    for (positions) |pos| {
        count_by_position[@intCast(usize, pos)] += 1;
    }

    var spent_by_pos = try arena.allocator.alloc(i32, @intCast(usize, max + 1));
    std.mem.set(i32, spent_by_pos, 0);
    var i: usize = 0;
    var count_from_left: i32 = 0;
    var count_from_right: i32 = 0;
    var spent_left: i32 = 0;
    var spent_right: i32 = 0;
    while (i < spent_by_pos.len) : (i += 1) {
        spent_left += count_from_left;
        spent_right += count_from_right;
        spent_by_pos[i] += spent_left;
        spent_by_pos[spent_by_pos.len - i - 1] += spent_right;
        count_from_left += count_by_position[i];
        count_from_right += count_by_position[count_by_position.len - i - 1];
    }

    var best_position: usize = 0;
    for (spent_by_pos) |spent, position| {
        if (spent < spent_by_pos[best_position]) {
            best_position = position;
        }
    }

    return spent_by_pos[best_position];
}

fn part2(arena: *ArenaAllocator, positions: []i32) anyerror!i32 {
    var max: i32 = positions[0];
    for (positions) |position| {
        max = std.math.max(max, position);
    }

    var count_by_position = try arena.allocator.alloc(i32, @intCast(usize, max + 1));
    std.mem.set(i32, count_by_position, 0);
    for (positions) |pos| {
        count_by_position[@intCast(usize, pos)] += 1;
    }

    var spent_by_pos = try arena.allocator.alloc(i32, @intCast(usize, max + 1));
    std.mem.set(i32, spent_by_pos, 0);
    var i: usize = 0;
    var count_from_left: i32 = 0;
    var count_from_right: i32 = 0;
    var count_from_left2: i32 = 0;
    var count_from_right2: i32 = 0;
    var spent_left: i32 = 0;
    var spent_right: i32 = 0;
    while (i < spent_by_pos.len) : (i += 1) {
        spent_left += count_from_left;
        spent_right += count_from_right;
        spent_by_pos[i] += spent_left;
        spent_by_pos[spent_by_pos.len - i - 1] += spent_right;
        count_from_left += count_from_left2 + count_by_position[i];
        count_from_right += count_from_right2 + count_by_position[count_by_position.len - i - 1];
        count_from_left2 += count_by_position[i];
        count_from_right2 += count_by_position[count_by_position.len - i - 1];
    }

    var best_position: usize = 0;
    for (spent_by_pos) |spent, position| {
        if (spent < spent_by_pos[best_position]) {
            best_position = position;
        }
    }

    return spent_by_pos[best_position];
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = try part1(&arena, input);
    print("Part 1: {d}", .{part1_result});

    const part2_result = try part2(&arena, input);
    print("Part 2: {d}", .{part2_result});
}
