const std = @import("std");
const utils = @import("utils");
const fs = std.fs;
const io = std.io;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const info = std.log.info;

pub const InputError = error{
    ReadFail,
};

pub fn read_input(allocator: *Allocator) anyerror![]i32 {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const buffer_size = 1024 * 1024;
    const buffer = try allocator.alloc(u8, buffer_size);
    const bytes_read = try file.readAll(buffer);
    if (bytes_read == buffer_size) {
        info("File too large :(", .{});
        return error.ReadFail;
    }
    const data = buffer[0..bytes_read];

    var numbers = try std.ArrayList(i32).initCapacity(allocator, 4096);
    var lines_it = utils.iterate_lines(data);
    while (lines_it.next()) |line| {
        const i = try std.fmt.parseInt(i32, line, 10);
        try numbers.append(i);
    }

    info("File ok :) Number of inputs: {d}", .{numbers.items.len});

    return numbers.items;
}

pub fn part1(_: []i32) i32 {
    return 0;
}


pub fn part2(_: []i32) i32 {
    return 0;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    const numbers = try read_input(allocator);

    const part1_result = part1(numbers);
    info("Part 1: number of increases: {d}", .{part1_result});  

    const part2_result = part2(numbers);
    info("Part 2: number of increases: {d}", .{part2_result});  
}

