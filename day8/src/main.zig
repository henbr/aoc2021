const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

const Values = struct {
    all_digits: [10]u8,
    output: [4]u8,
};

fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![]Values {
    var values = try std.ArrayList(Values).initCapacity(&arena.allocator, 4096);
    while (lines_it.next()) |line| {
        var signals = std.mem.tokenize(u8, line, " |");
        var v: Values = undefined;
        for (v.all_digits) |*digit| {
            digit.* = parseSignals(signals.next().?);
        }
        for (v.output) |*digit| {
            digit.* = parseSignals(signals.next().?);
        }
        try values.append(v);
    }

    print("File ok :) Number of inputs: {d}", .{values.items.len});

    return values.items;
}

fn parseSignals(signals: []const u8) u8 {
    var res: u8 = 0;
    for (signals) |signal| {
        switch (signal) {
            'a' => res |= 1,
            'b' => res |= 2,
            'c' => res |= 4,
            'd' => res |= 8,
            'e' => res |= 16,
            'f' => res |= 32,
            'g' => res |= 64,            
            else => unreachable,
        }
    }
    return res;
}

fn mapDigits(scrambled: [10]u8) [10]u8 {
    var d = std.mem.zeroes([10]u8);
    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 2) {
            d[1] = digit;
        }
    }

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 4) {
            d[4] = digit;
        }
    }

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 3) {
            d[7] = digit;
        }
    }

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 7) {
            d[8] = digit;
        }
    }

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 5 and digit & d[1] == d[1]) {
            d[3] = digit;
        }
    }

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 6 and digit & d[4] == d[4]) {
            d[9] = digit;
        }
    }    

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 6 and digit & d[7] == d[7] and digit != d[9]) {
            d[0] = digit;
        }
    }    

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 6 and digit != d[9] and digit != d[0]) {
            d[6] = digit;
        }
    }    

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 5 and @popCount(u8, digit & d[6]) == 5) {
            d[5] = digit;
        }
    }    

    for (scrambled) |digit| {
        if (@popCount(u8, digit) == 5 and digit != d[5] and digit != d[3]) {
            d[2] = digit;
        }
    }

    return d;
}

fn part1(all_values: []Values) i32 {
    var occurences: i32 = 0;
    for (all_values) |values| {
        const d = mapDigits(values.all_digits);        
        for (values.output) |o| {
            if (o == d[1] or o == d[4] or o == d[7] or o == d[8]) {
                occurences += 1;
            }
        }
    }
    return occurences;
}

fn part2(all_values: []Values) i32 {
    var sum: i32 = 0;
    for (all_values) |values| {
        const mapped = mapDigits(values.all_digits);        
        var res: i32 = 0;
        for (values.output) |o| {
            for (mapped) |d, i| {
                if (d == o) {
                    res *= 10;
                    res += @intCast(i32, i);
                }
            }
        }
        sum += res;
    }
    return sum;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(input);
    print("Part 1: {d}", .{part1_result});

    const part2_result = part2(input);
    print("Part 2: {d}", .{part2_result});
}
