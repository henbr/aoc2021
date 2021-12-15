const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

const Rule = struct {
    pair: [2]u8,
    inserted: u8,
};

const Input = struct {
    template: []u8,
    rules: []Rule,
};

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror!Input {
    const template = lines_it.next().?;
    _ = lines_it.next(); // Skip empty line
    var rules = try std.ArrayList(Rule).initCapacity(&arena.allocator, 4096);
    while (lines_it.next()) |line| {
        var tokens = std.mem.tokenize(u8, line, " ->");
        const rule = tokens.next().?;
        const inserted = tokens.next().?;
        try rules.append(Rule{ .pair = .{ rule[0], rule[1] }, .inserted = inserted[0] });
    }
    print("File ok :) Number of inputs: {d}", .{rules.items.len});
    return Input{
        .template = template,
        .rules = rules.items,
    };
}

fn part1(arena: *ArenaAllocator, input: Input) anyerror!i32 {
    var template = input.template;
    var step: i32 = 0;
    while (step < 10) : (step += 1) {
        var result = try std.ArrayList(u8).initCapacity(&arena.allocator, 4096);
        for (template) |t| {
            if (result.items.len == 0) {
                try result.append(t);
                continue;
            }
            const prev = result.items[result.items.len - 1];
            for (input.rules) |r| {
                if (r.pair[0] == prev and r.pair[1] == t) {
                    try result.append(r.inserted);
                    break;
                }
            }
            try result.append(t);
        }
        template = result.items;
    }
    var counts = std.mem.zeroes([256]i32);
    for (template) |t| {
        counts[t] += 1;
    }
    var min: i32 = std.math.maxInt(i32);
    var max: i32 = std.math.minInt(i32);
    for (counts) |c| {
        if (c == 0) {
            continue;
        }
        min = std.math.min(c, min);
        max = std.math.max(c, max);
    }
    return max - min;
}

const Pair = struct {
    pair: [2]u8,
    count: i64,
};

fn insertPair(pair_list: *std.ArrayList(Pair), pair: [2]u8, count: i64) anyerror!void {
    for (pair_list.items) |*p| {
        if (std.mem.eql(u8, &p.pair, &pair)) {
            p.count += count;
            break;
        }
    } else {
        try pair_list.append(Pair{ .pair = pair, .count = count });
    }
}

fn part2(arena: *ArenaAllocator, input: Input) anyerror!i64 {
    // Pairify initial string
    var initial_pairs = try std.ArrayList(Pair).initCapacity(&arena.allocator, 4096);
    for (input.template) |t, i| {
        const next_t = if (i + 1 < input.template.len) input.template[i + 1] else ' ';
        try insertPair(&initial_pairs, .{ t, next_t }, 1);
    }

    // Run the insertion process
    var step: i32 = 0;
    var prev_pairs = initial_pairs.items;
    while (step < 40) : (step += 1) {
        var new_pairs = try std.ArrayList(Pair).initCapacity(&arena.allocator, 4096);
        for (prev_pairs) |prev_pair| {
            for (input.rules) |rule| {
                const p = prev_pair.pair;
                if (std.mem.eql(u8, &rule.pair, &p)) {
                    try insertPair(&new_pairs, .{ p[0], rule.inserted }, prev_pair.count);
                    try insertPair(&new_pairs, .{ rule.inserted, p[1] }, prev_pair.count);
                    break;
                }
            } else {
                try insertPair(&new_pairs, prev_pair.pair, prev_pair.count);
            }
        }
        prev_pairs = new_pairs.items;
    }

    // Count elements
    var counts = std.mem.zeroes([256]i64);
    for (prev_pairs) |p| {
        counts[p.pair[0]] += p.count;
    }
    var min: i64 = std.math.maxInt(i64);
    var max: i64 = std.math.minInt(i64);
    for (counts) |c| {
        if (c == 0) {
            continue;
        }
        min = std.math.min(c, min);
        max = std.math.max(c, max);
    }
    const res = max - min;

    return res;
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
