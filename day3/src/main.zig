const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const info = std.log.info;

pub fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror![][]const u8 {
    var allocator = &arena.allocator;
    var numbers = try std.ArrayList([]const u8).initCapacity(allocator, 4096);
    while (lines_it.next()) |line| {
        try numbers.append(line);
    }

    info("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}


pub fn part1(numbers: [][]const u8) i64 {
    if (numbers.len == 0) {
        return @intCast(i64, -1); // ???
    }

    var popcount = std.mem.zeroes([32]u32);
    for (numbers) |number| {
        for (number) |bit, index| {
            if (bit == '1') {
                popcount[index] += 1;
            }
        }
    }

    const num_size = numbers[0].len;
    var gamma: u32 = 0;
    var i: usize = 0;
    while (i < num_size) : (i += 1) {
        if (popcount[i] > numbers.len / 2) {
            gamma = (gamma << 1) | 1;
        } else {
            gamma = gamma << 1;
        }
    }

    var mask: u32 = 0;
    for (numbers[0]) |_| {
        mask = (mask << 1) | 1;
    }
    const epsilon = ~gamma & mask;

    const power_consumption = gamma * epsilon;
    return power_consumption;
}

const Strategy = enum {
    MostCommon,
    LeastCommon
};

pub fn getRemainingNumber(arena: *ArenaAllocator, strategy: Strategy, numbers: [][]const u8) anyerror!i64 {
    var allocator = &arena.allocator;

    var remaining = try std.ArrayList(usize).initCapacity(allocator, numbers.len);
    for (numbers) |_, i| {
        remaining.appendAssumeCapacity(i);
    }

    var bitpos: usize = 0;
    while (bitpos < numbers[0].len) : (bitpos += 1) {
        var popcount: usize = 0;
        var i: usize = 0;
        for (remaining.items) |index| {
            if (numbers[index][bitpos] == '1') {
                popcount += 1;
            }
        }

        var bit_to_keep: u8 = undefined;
        if (strategy == Strategy.MostCommon and popcount >= (remaining.items.len - popcount)) {
            bit_to_keep = '1';
        } else if (strategy == Strategy.LeastCommon and popcount < (remaining.items.len - popcount)) { 
            bit_to_keep = '1';
        } else {
            bit_to_keep = '0';
        }

        var j: isize = 0;
        while (j < remaining.items.len and remaining.items.len > 1) : (j += 1) {
            i = @intCast(usize, j);
            if (numbers[remaining.items[i]][bitpos] != bit_to_keep) {
                _ = remaining.swapRemove(i);
                //_ = remaining.orderedRemove(i);
                j -= 1;
            }
        }

        if (remaining.items.len == 1) {
            break;
        }
    }

    if (remaining.items.len == 1) {
        const number = numbers[remaining.items[0]];
        var integer: u32 = 0;
        for (number) |bit| {
            if (bit == '1') {
                integer = (integer << 1) | 1;
            } else {
                integer = integer << 1;
            }
        }
        return integer;
    }

    unreachable; // :)
}

pub fn part2(arena: *ArenaAllocator, numbers: [][]const u8) anyerror!i64 {
    const oxygen_generator_rating = try getRemainingNumber(arena, Strategy.MostCommon, numbers);
    const co2_scrubber_rating = try getRemainingNumber(arena, Strategy.LeastCommon, numbers);
    return oxygen_generator_rating * co2_scrubber_rating;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(input);
    info("Part 1: {d}", .{part1_result});

    const part2_result = try part2(&arena, input);
    info("Part 2: {d}", .{part2_result});
}
