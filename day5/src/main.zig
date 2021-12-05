const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const max = std.math.max;
const min = std.math.min;
const clamp = std.math.clamp;
const absInt = std.math.absInt;
const info = std.log.info;

const Line = struct {
    x0: i32,
    y0: i32,
    x1: i32,
    y1: i32,
};

pub fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]Line {
    var allocator = &arena.allocator;
    var lines = try std.ArrayList(Line).initCapacity(allocator, 4096);
    while (lines_it.next()) |line| {
        var line_it = std.mem.tokenize(u8, line, ", ->");
        var coords = std.mem.zeroes([4]i32);
        var i: usize = 0;
        while (line_it.next()) |num| : (i += 1) {
            coords[i] = try std.fmt.parseInt(i32, num, 10);
        }
        try lines.append(Line{
            .x0 = coords[0],
            .y0 = coords[1],
            .x1 = coords[2],
            .y1 = coords[3],
        });
    }

    info("File ok :) Number of inputs: {d}", .{lines.items.len});

    return lines.items;
}

pub fn pointToKey(x: i32, y: i32) u32 {
    const ux = @intCast(u32, x);
    const uy = @intCast(u32, y);
    return ((ux & 0xffff) << 16) | (uy & 0xffff);
}

pub fn keyToPoint(key: u32) struct { x: i32, y: i32 } {
    const ux = key >> 16;
    const uy = key & 0xffff;
    const x = @intCast(u32, ux);
    const y = @intCast(u32, uy);
    return .{ .x = x, .y = y };
}

pub fn countOverlappingPoints(arena: *ArenaAllocator, lines: []Line) anyerror!i32 {
    var map = std.AutoArrayHashMap(u32, i32).init(&arena.allocator);
    for (lines) |line| {
        const dx = line.x1 - line.x0;
        const dy = line.y1 - line.y0;
        const xslope = clamp(dx, -1, 1);
        const yslope = clamp(dy, -1, 1);
        const length = max(try absInt(dx), try absInt(dy));
        var x = line.x0;
        var y = line.y0;
        var i: i32 = 0;
        while (i <= length) : (i += 1) {
            var key = pointToKey(x, y);
            var count: i32 = undefined;
            if (map.get(key)) |c| {
                count = c + 1;
            } else {
                count = 1;
            }
            try map.put(key, count);
            x += xslope;
            y += yslope;
        }
    }
    var overlaps: i32 = 0;
    for (map.values()) |value| {
        if (value > 1) {
            overlaps += 1;
        }
    }
    return overlaps;
}

pub fn part1(arena: *ArenaAllocator, lines: []Line) anyerror!i32 {
    var orthogonal = try std.ArrayList(Line).initCapacity(&arena.allocator, lines.len);
    for (lines) |*line| {
        if ((line.x0 == line.x1) or (line.y0 == line.y1)) {
            try orthogonal.append(line.*);
        }
    }
    return try countOverlappingPoints(arena, orthogonal.items);
}

pub fn part2(arena: *ArenaAllocator, lines: []Line) anyerror!i32 {
    return try countOverlappingPoints(arena, lines);
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = try part1(&arena, input);
    info("Part 1: {d}", .{part1_result});

    const part2_result = try part2(&arena, input);
    info("Part 2: {d}", .{part2_result});
}
