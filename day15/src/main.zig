const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

const Map = struct {
    risk: []u32,
    width: usize,
    height: usize,
};

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror!Map {
    var risk = try std.ArrayList(u32).initCapacity(&arena.allocator, 128 * 128);
    var width: usize = 0;
    while (lines_it.next()) |line| {
        for (line) |l| {
            try risk.append(l - '0');
        }
        width = line.len;
    }
    const height = risk.items.len / width;
    print("File ok :) Number of inputs: {d}", .{risk.items.len});
    return Map{
        .risk = risk.items,
        .width = width,
        .height = height,
    };
}

const Vertex = struct {
    index: usize,
    risk: u32,
    dist: u32,
    prev: ?usize,
    neighbors: []usize,
};

fn lessThan(a: u64, b: u64) std.math.Order {
    return std.math.order(a & ((1 << 32) - 1), b & ((1 << 32) - 1));
}

fn part1(arena: *ArenaAllocator, map: Map) anyerror!u32 {
    var vertices_list = try std.ArrayList(Vertex).initCapacity(&arena.allocator, 128 * 128);
    for (map.risk) |risk, offset| {
        var neighbors = try std.ArrayList(usize).initCapacity(&arena.allocator, 4);
        var x = offset % map.width;
        var y = offset / map.width;
        if (x > 0) try neighbors.append(offset - 1);
        if (x < map.width - 1) try neighbors.append(offset + 1);
        if (y > 0) try neighbors.append(offset - map.width);
        if (y < map.height - 1) try neighbors.append(offset + map.width);
        try vertices_list.append(.{
            .index = offset,
            .risk = risk,
            .dist = 9999999,
            .prev = null,
            .neighbors = neighbors.items,
        });
    }
    const vertices = vertices_list.items;

    vertices[0].dist = 0;

    var pg = std.PriorityQueue(u64, lessThan).init(&arena.allocator);
    try pg.ensureTotalCapacity(128 * 128);
    var i: usize = 0;
    while (i < vertices.len) : (i += 1) {
        const offset = vertices.len - i - 1;
        try pg.add(@intCast(u64, offset << 32) + @intCast(u64, vertices[offset].dist & ((1 << 32) - 1)));
    }

    while (pg.count() > 0) {
        const entry = pg.remove();
        const entry_index = @intCast(usize, entry >> 32);
        const u = vertices[entry_index];
        for (u.neighbors) |n| {
            var v = &vertices[n];
            const alt = u.dist + v.risk;
            if (alt < v.dist) {
                const old_entry = @intCast(u64, n << 32) + @intCast(u64, v.dist & ((1 << 32) - 1));
                v.dist = alt;
                v.prev = u.index;
                try pg.update(old_entry, @intCast(u64, n << 32) + @intCast(u64, v.dist & ((1 << 32) - 1)));
            }
        }
    }

    var path = try std.ArrayList(usize).initCapacity(&arena.allocator, map.risk.len);
    try path.append(0);
    var target = vertices.len - 1;
    var sum = vertices[target].risk;
    while (target != 0) {
        const v = &vertices[target];
        target = if (v.prev) |prev| prev else unreachable;
        try path.append(v.index);
        sum += v.risk;
    }
    sum -= map.risk[map.risk.len - 1];

    var row = try std.ArrayList(u8).initCapacity(&arena.allocator, 128);
    for (map.risk) |n, p_offset| {
        for (path.items) |p| {
            if (p == p_offset) {
                try row.append('.');
                break;
            }
        } else {
            try row.append('0' + @intCast(u8, n));
        }
    }

    return sum;
}

fn part2(arena: *ArenaAllocator, map: Map) anyerror!u32 {
    var risk = try std.ArrayList(u32).initCapacity(&arena.allocator, map.risk.len * 25);
    const new_width = map.width * 5;
    const new_height = map.height * 5;
    var y: usize = 0;
    while (y < new_height) : (y += 1) {
        const y_inc = y / map.height;
        const old_y = y % map.height;
        var x: usize = 0;
        while (x < new_width) : (x += 1) {
            const x_inc = x / map.width;
            const old_x = x % map.width;
            const old_offset = old_y * map.width + old_x;
            const new_risk = (map.risk[old_offset] - 1 + @intCast(u32, y_inc + x_inc)) % 9 + 1;
            try risk.append(new_risk);
        }
    }
    const expanded_map = Map{
        .risk = risk.items,
        .width = new_width,
        .height = new_height,
    };
    return part1(arena, expanded_map);
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
