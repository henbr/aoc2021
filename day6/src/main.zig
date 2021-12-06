const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]i32 {
    var numbers = try std.ArrayList(i32).initCapacity(&arena.allocator, 4096);
    const line = lines_it.next() orelse unreachable;
    var numbers_it = std.mem.tokenize(u8, line, ",");
    while (numbers_it.next()) |num| {
        const i = try std.fmt.parseInt(i32, num, 10);
        try numbers.append(i);
    }

    print("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}

fn part1(arena: *ArenaAllocator, inputFishes: []i32) anyerror!i32 {
    var fishes = try std.ArrayList(i32).initCapacity(&arena.allocator, 1024 * 1024);
    try fishes.appendSlice(inputFishes);

    var day: usize = 0;
    while (day < 80) : (day += 1) {
        var fish_count = fishes.items.len;
        var i: usize = 0;
        while (i < fish_count) : (i += 1) {
            if (fishes.items[i] == 0) {
                fishes.items[i] = 6;
                try fishes.append(8);
            } else {
                fishes.items[i] -= 1;
            }
        }
    }

    return @intCast(i32, fishes.items.len);
}

fn part2(inputFishes: []i32) u64 {
    var fishCountByAge = std.mem.zeroes([9]u64);
    for (inputFishes) |inputFish| {
        fishCountByAge[@intCast(usize, inputFish)] += 1;
    }

    var day: usize = 0;
    while (day < 256) : (day += 1) {
        const numResetFishes = fishCountByAge[0];
        var i: usize = 1;
        while (i < fishCountByAge.len) : (i += 1) {
            fishCountByAge[i - 1] = fishCountByAge[i];
        }
        fishCountByAge[6] += numResetFishes;
        fishCountByAge[8] = numResetFishes;
    }

    var sum: u64 = 0;
    for (fishCountByAge) |count| {
        sum += count;
    } 

    return sum;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(&arena, input);
    print("Part 1: {d}", .{part1_result});

    const part2_result = part2(input);
    print("Part 2: {d}", .{part2_result});
}
