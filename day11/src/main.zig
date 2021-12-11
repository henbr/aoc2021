const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const sort = std.sort;

const print = utils.print;
const desc_i32 = sort.desc(i32);

const OctupusMap = struct {
    width: usize,
    height: usize,
    energy: []i32,
    flashed: []bool,
    steps: i32,
};

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror!OctupusMap {
    var numbers = try std.ArrayList(i32).initCapacity(&arena.allocator, 4096 * 4);
    var width: usize = 0;
    while (lines_it.next()) |line| {
        for (line) |h| {
            try numbers.append(@intCast(i32, h - 48));
        }
        width = line.len;
    }
    print("File ok :) Number of inputs: {d}", .{numbers.items.len});
    var flashed = try arena.allocator.alloc(bool, numbers.items.len);
    std.mem.set(bool, flashed, false);
    return OctupusMap{
        .width = width,
        .height = numbers.items.len / width,
        .energy = numbers.items,
        .flashed = flashed,
        .steps = 0,
    };
}

fn increaseEnergy(map: *OctupusMap, x: i32, y: i32) void {
    if (x < 0 or y < 0 or x >= map.width or y >= map.height) {
        return;
    }
    const offset = @intCast(usize, y) * map.width + @intCast(usize, x);
    map.energy[offset] += 1;
}

fn runStep(map: *OctupusMap) i32 {
    map.steps += 1;

    for (map.energy) |*e| {
        e.* += 1;
    }

    while (true) {
        var has_flashed = false;
        var y: i32 = 0;
        while (y < map.height) : (y += 1) {
            var x: i32 = 0;
            while (x < map.width) : (x += 1) {
                const offset = @intCast(usize, y) * map.width + @intCast(usize, x);
                if (map.energy[offset] > 9 and !map.flashed[offset]) {
                    map.flashed[offset] = true;
                    increaseEnergy(map, x - 1, y - 1);
                    increaseEnergy(map, x, y - 1);
                    increaseEnergy(map, x + 1, y - 1);
                    increaseEnergy(map, x - 1, y);
                    increaseEnergy(map, x + 1, y);
                    increaseEnergy(map, x - 1, y + 1);
                    increaseEnergy(map, x, y + 1);
                    increaseEnergy(map, x + 1, y + 1);
                    has_flashed = true;
                }
            }
        }
        if (!has_flashed) {
            break;
        }
    }
    var num_flashed: i32 = 0;
    for (map.flashed) |flashed, offset| {
        if (flashed) {
            num_flashed += 1;
            map.energy[offset] = 0;
            map.flashed[offset] = false;
        }
    }
    return num_flashed;
}

fn part1(map: *OctupusMap) i32 {
    var sum: i32 = 0;
    var step: i32 = 0;
    while (step < 100) : (step += 1) {
        sum += runStep(map);
    }
    return sum;
}

fn part2(map: *OctupusMap) i32 {
    while (runStep(map) != @intCast(i32, map.width * map.height)) {}
    return map.steps;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    var input = try readInput(&arena, &lines_it);

    const part1_result = part1(&input);
    print("Part 1: {d}", .{part1_result});

    const part2_result = part2(&input);
    print("Part 2: {d}", .{part2_result});
}
