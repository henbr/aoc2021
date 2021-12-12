const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;
const eql = std.mem.eql;
const isLower = std.ascii.isLower;

const Kind = union(enum) {
    Start,
    End,
    Small,
    Large,
};

const Cave = struct {
    name: []const u8,
    kind: Kind,
    visits: i32,
};

const Connection = struct { left: usize, right: usize };

const CaveSystem = struct {
    caves: []Cave,
    connections: []Connection,
};

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror!CaveSystem {
    var caves = try std.ArrayList(Cave).initCapacity(&arena.allocator, 100);
    var connections = try std.ArrayList(Connection).initCapacity(&arena.allocator, 100);
    while (lines_it.next()) |line| {
        var parts = std.mem.tokenize(u8, line, "-");
        const left = try appendOrGetCave(&caves, parts.next().?);
        const right = try appendOrGetCave(&caves, parts.next().?);
        try connections.append(Connection{ .left = left, .right = right });
    }
    print("File ok :) Number of inputs: {d}", .{connections.items.len});
    return CaveSystem{
        .caves = caves.items,
        .connections = connections.items,
    };
}

fn appendOrGetCave(caves: *std.ArrayList(Cave), name: []const u8) anyerror!usize {
    for (caves.items) |cave, i| {
        if (eql(u8, name, cave.name)) {
            return i;
        }
    } else {
        if (eql(u8, name, "start")) {
            try caves.append(Cave{ .name = name, .kind = Kind.Start, .visits = 0 });
        } else if (eql(u8, name, "end")) {
            try caves.append(Cave{ .name = name, .kind = Kind.End, .visits = 0 });
        } else if (isLower(name[0])) {
            try caves.append(Cave{ .name = name, .kind = Kind.Small, .visits = 0 });
        } else {
            try caves.append(Cave{ .name = name, .kind = Kind.Large, .visits = 0 });
        }
        return caves.items.len - 1;
    }
}

fn countPaths(system: *CaveSystem, cave_index: usize, small_visited_twice: bool) i32 {
    var cave = &system.caves[cave_index];

    switch (cave.kind) {
        Kind.End => return 1,
        Kind.Start => if (cave.visits > 0) return 0,
        Kind.Large => {},
        Kind.Small => if (cave.visits > 0 and small_visited_twice) return 0,
    }

    const visiting_small_second_time = cave.visits >= 1 and cave.kind == Kind.Small;

    cave.visits += 1;

    var res: i32 = 0;
    for (system.connections) |con| {
        if (cave_index == con.left) {
            res += countPaths(system, con.right, small_visited_twice or visiting_small_second_time);
        }
        if (cave_index == con.right) {
            res += countPaths(system, con.left, small_visited_twice or visiting_small_second_time);
        }
    }

    cave.visits -= 1;

    return res;
}

fn part1(system: *CaveSystem) i32 {
    for (system.caves) |cave, i| {
        if (cave.kind == Kind.Start) {
            return countPaths(system, i, true);
        }
    }
    unreachable;
}

fn part2(system: *CaveSystem) i32 {
    for (system.caves) |cave, i| {
        if (cave.kind == Kind.Start) {
            return countPaths(system, i, false);
        }
    }
    unreachable;
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
