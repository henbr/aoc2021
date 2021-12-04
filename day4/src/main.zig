const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const info = std.log.info;

const Cell = struct {
    number: i32,
    marked: bool
};

const Bingo = struct {
    drawn_numbers: []i32,
    board_count: usize,
    board_lines: [][]Cell,
};

pub fn readInput(arena: *ArenaAllocator, lines_it: *utils.FileLineIterator) anyerror!Bingo {
    var allocator = &arena.allocator;
    const drawn_line = lines_it.next() orelse unreachable;
    var drawn_it = std.mem.tokenize(u8, drawn_line, ",");
    var drawn_numbers = try std.ArrayList(i32).initCapacity(allocator, 1024);
    while (drawn_it.next()) |drawn| {
        try drawn_numbers.append(try std.fmt.parseInt(i32, drawn, 10));
    }

    var cells = try std.ArrayList(Cell).initCapacity(allocator, 4096);
    var board_lines = try std.ArrayList([]Cell).initCapacity(allocator, 1024);
    var board_count: usize = 0;
    while (lines_it.next()) |line| {
        if (line.len == 0) {
            board_count += 1;
            continue;
        }

        const line_start = cells.items.len;
        var line_it = std.mem.tokenize(u8, line, " ");
        while (line_it.next()) |num| {
            if (num.len == 0) {
                continue;
            }
            try cells.append(Cell {
                .number = try std.fmt.parseInt(i32, num, 10),
                .marked = false,
            });
        }       

        try board_lines.append(cells.items[line_start..]);
    }

    info("File ok :) Number of boards: {d}", .{board_count});

    return Bingo {
        .drawn_numbers = drawn_numbers.items,
        .board_count = board_count,
        .board_lines = board_lines.items,
    };
}

fn checkRow(board: [][]const Cell, row: usize) bool {
    for (board[row]) |*cell| {
        if (!cell.marked) {
            return false;
        }
    }
    return true;
}

fn checkCol(board: [][]const Cell, col: usize) bool {
    for (board) |line| {
        if (!line[col].marked) {
            return false;
        }
    }
    return true;
}

fn getBoardScore(board: [][]const Cell, drawn_number: i32) i32 {
    var sum: i32 = 0;
    for (board) |line| {
        for (line) |*cell| {
            if (!cell.marked) {
                sum += cell.number;
            }
        }
    }   
    return sum * drawn_number;
}

fn playBoard(bingo: Bingo, board_index: usize, drawn_number: i32) ?i32 {
    const board_size = bingo.board_lines.len / bingo.board_count;
    const start = board_size * board_index;
    const end = start + board_size;
    const board = bingo.board_lines[start..end];

    // Mark numbers
    for (board) |line, row| {
        for (line) |*cell, col| {
            if (cell.number == drawn_number) {
                cell.marked = true;
                if (checkCol(board, col) or checkRow(board, row)) {
                    return getBoardScore(board, drawn_number);
                }
            }
        }
    }
    
    return null;
}

pub fn part1(bingo: Bingo) i32 {
    for (bingo.drawn_numbers) |drawn_number| {
        var board_index: usize = 0;
        while (board_index < bingo.board_count) : (board_index += 1) {
            if (playBoard(bingo, board_index, drawn_number)) |score| {
                return score;
            }
        }       
    }
    
    // No winner
    return -1;
}

pub fn part2(bingo: Bingo) i32 {
    var winning_board_count: i32 = 0;
    var winning_boards = std.mem.zeroes([1024]bool);
    for (bingo.drawn_numbers) |drawn_number| {
        var board_index: usize = 0;
        while (board_index < bingo.board_count) : (board_index += 1) {
            if (playBoard(bingo, board_index, drawn_number)) |score| {
                if (!winning_boards[board_index]) {
                    winning_boards[board_index] = true;
                    winning_board_count += 1;
                }
                if (winning_board_count == bingo.board_count) {
                    return score;
                }
            }
        }       
    }
    
    // No winner
    return -1;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    const input = try readInput(&arena, &lines_it);

    const part1_result = part1(input);
    info("Part 1: {d}", .{part1_result});

    const part2_result = part2(input);
    info("Part 2: {d}", .{part2_result});
}
