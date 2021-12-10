const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![][]u8 {
    var lines = try std.ArrayList([]u8).initCapacity(&arena.allocator, 4096);
    while (lines_it.next()) |line| {
        try lines.append(line);
    }
    print("File ok :) Number of inputs: {d}", .{lines.items.len});
    return lines.items;
}

const Result = struct {part1: i32, part2: i64};

fn part1And2(arena: *ArenaAllocator, lines: [][]u8) anyerror!Result {
    var stack = try std.ArrayList(u8).initCapacity(&arena.allocator, 4096);
    var corrupt_score_sum: i32 = 0;
    var incomplete_scores = try std.ArrayList(i64).initCapacity(&arena.allocator, 4096);
    for (lines) |line| {
        stack.clearRetainingCapacity();
        var corrupt_score: i32 = 0;
        for (line) |chr| {
            if (chr == '(' or chr == '[' or chr == '{' or chr == '<' ) {
                try stack.append(chr);
            } else if (chr == ')' or  chr == ']' or chr == '}' or chr == '>') {
                const opening = stack.pop();
                if (corrupt_score ==  0) {
                    if (chr == ')' and opening != '(') corrupt_score = 3;
                    if (chr == ']' and opening != '[') corrupt_score = 57;
                    if (chr == '}' and opening != '{') corrupt_score = 1197;
                    if (chr == '>' and opening != '<') corrupt_score = 25137;
                }
            } else {
                unreachable;
            }
        }
        corrupt_score_sum += corrupt_score;   

        var incomplete_score: i64 = 0;
        if (corrupt_score == 0) {
            while(stack.popOrNull()) |chr| {
                const chr_score: i32 = switch(chr) {
                    '(' => 1,
                    '[' => 2,
                    '{' => 3,
                    '<' => 4,
                    else => unreachable,
                };
                incomplete_score *= 5;
                incomplete_score += chr_score;
            }
            try incomplete_scores.append(incomplete_score);
        }
    }

    std.sort.sort(i64, incomplete_scores.items, {}, comptime std.sort.desc(i64));
    const incomplete_score_middle = incomplete_scores.items[incomplete_scores.items.len / 2];

    return Result {
        .part1 = corrupt_score_sum,
        .part2 = incomplete_score_middle,
    };
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const result = try part1And2(&arena, input);
    print("Part 1: {d}", .{result.part1});
    print("Part 2: {d}", .{result.part2});
}
