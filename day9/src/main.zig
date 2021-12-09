const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const sort = std.sort;

const print = utils.print;
const desc_i32 = sort.desc(i32);

const HeightMap = struct {
    width: usize,
    height: usize,
    map: []i32,
    visited: []bool,
};

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror!HeightMap {
    var numbers = try std.ArrayList(i32).initCapacity(&arena.allocator, 4096 * 4);
    var width: usize = 0;
    while (lines_it.next()) |line| {
        for (line) |h| {
            try numbers.append(@intCast(i32, h - 48));
        }
        width = line.len;
    }
    print("File ok :) Number of inputs: {d}", .{numbers.items.len});
    var visited = try arena.allocator.alloc(bool, numbers.items.len);
    std.mem.set(bool, visited, false);
    return HeightMap{
        .width = width,
        .height = numbers.items.len / width,
        .map = numbers.items,
        .visited = visited,
    };
}

fn getHeight(hm: *const HeightMap, x: i32, y: i32, default: i32) i32 {
    if (x < 0 or y < 0 or x >= hm.width or y >= hm.height) {
        return default;
    }
    const offset = @intCast(usize, y) * hm.width + @intCast(usize, x);
    return hm.map[offset];
}

fn isLowPoint(hm: *const HeightMap, x: i32, y: i32) bool {
    var h = getHeight(hm, x, y, 0);
    var h1 = getHeight(hm, x + 1, y, h + 1);
    var h2 = getHeight(hm, x - 1, y, h + 1);
    var h3 = getHeight(hm, x, y + 1, h + 1);
    var h4 = getHeight(hm, x, y - 1, h + 1);
    return h < h1 and h < h2 and h < h3 and h < h4;
}

fn calculateBasinSize(hm: *const HeightMap, x: i32, y: i32) i32 {
    if (x < 0 or y < 0 or x >= hm.width or y >= hm.height) {
        return 0;
    }

    const offset = @intCast(usize, y) * hm.width + @intCast(usize, x);
    if (hm.visited[offset]) {
        return 0;
    }
    hm.visited[offset] = true;

    var h = getHeight(hm, x, y, 0);
    if (h == 9) {
        return 0;
    }

    var h1 = getHeight(hm, x + 1, y, h + 1);
    var h2 = getHeight(hm, x - 1, y, h + 1);
    var h3 = getHeight(hm, x, y + 1, h + 1);
    var h4 = getHeight(hm, x, y - 1, h + 1);

    var b1 = if (h1 >= h) calculateBasinSize(hm, x + 1, y) else 0;
    var b2 = if (h2 >= h) calculateBasinSize(hm, x - 1, y) else 0;
    var b3 = if (h3 >= h) calculateBasinSize(hm, x, y + 1) else 0;
    var b4 = if (h4 >= h) calculateBasinSize(hm, x, y - 1) else 0;

    return 1 + b1 + b2 + b3 + b4;
}

fn part1(heightMap: *const HeightMap) i32 {
    var sum: i32 = 0;
    var y: i32 = 0;
    while (y < heightMap.height) : (y += 1) {
        var x: i32 = 0;
        while (x < heightMap.width) : (x += 1) {
            if (isLowPoint(heightMap, x, y)) {
                var h = getHeight(heightMap, x, y, 0);
                sum += h + 1;
            }
        }
    }
    return sum;
}

fn part2(arena: *ArenaAllocator, heightMap: *const HeightMap) anyerror!i32 {
    var basin_sizes = try std.ArrayList(i32).initCapacity(&arena.allocator, 4096);
    var y: i32 = 0;
    while (y < heightMap.height) : (y += 1) {
        var x: i32 = 0;
        while (x < heightMap.width) : (x += 1) {
            if (isLowPoint(heightMap, x, y)) {
                try basin_sizes.append(calculateBasinSize(heightMap, x, y));
            }
        }
    }
    sort.sort(i32, basin_sizes.items, {}, desc_i32);
    return basin_sizes.items[0] * basin_sizes.items[1] * basin_sizes.items[2];
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(&input);
    print("Part 1: {d}", .{part1_result});

    const part2_result = try part2(&arena, &input);
    print("Part 2: {d}", .{part2_result});
}
