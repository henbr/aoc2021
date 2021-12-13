const std = @import("std");
const utils = @import("utils");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const print = utils.print;

const Fold = union(enum) {
    Horizontal: i32,
    Vertical: i32,
};

const Folding = struct {
    points: [][2]i32,
    folds: []Fold,
};

fn readInput(arena: *ArenaAllocator) anyerror!Folding {
    var lines_it = try utils.iterateLinesInFile(&arena.allocator, "input.txt");
    defer lines_it.deinit();

    var points = try std.ArrayList([2]i32).initCapacity(&arena.allocator, 4096);
    while (lines_it.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var point = std.mem.tokenize(u8, line, ",");
        try points.append(.{ try std.fmt.parseInt(i32, point.next().?, 10), try std.fmt.parseInt(i32, point.next().?, 10) });
    }

    var folds = try std.ArrayList(Fold).initCapacity(&arena.allocator, 4096);
    while (lines_it.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const fold_part = line["fold along ".len..];
        var point = std.mem.tokenize(u8, fold_part, "=");
        const axis = point.next().?;
        const position = try std.fmt.parseInt(i32, point.next().?, 10);
        const fold = switch (axis[0]) {
            'x' => Fold{ .Vertical = position },
            'y' => Fold{ .Horizontal = position },
            else => unreachable,
        };
        try folds.append(fold);
    }

    return Folding{
        .points = points.items,
        .folds = folds.items,
    };
}

fn pointLessThan(_: void, lhs: [2]i32, rhs: [2]i32) bool {
    const dx = lhs[0] - rhs[0];
    const dy = lhs[1] - rhs[1];
    if (dy < 0) {
        return true;
    } else if (dy > 0) {
        return false;
    } else if (dx < 0) {
        return true;
    } else {
        return false;
    }
}

fn foldPoints(points: [][2]i32, fold: Fold) void {
    for (points) |*point| {
        var px = point[0];
        var py = point[1];
        switch (fold) {
            Fold.Horizontal => |y| {
                if (py > y) {
                    py = y - (py - y);
                }
            },
            Fold.Vertical => |x| {
                if (px > x) {
                    px = x - (px - x);
                }
            },
        }
        point[0] = px;
        point[1] = py;
    }
}

fn part1(folding: Folding) i32 {
    foldPoints(folding.points, folding.folds[0]);
    std.sort.sort([2]i32, folding.points, {}, pointLessThan);
    var sum: i32 = 1;
    var prev = folding.points[0];
    for (folding.points) |p| {
        if (!std.mem.eql(i32, &prev, &p)) {
            sum += 1;
            prev = p;
        }
    }
    return sum;
}

fn part2(folding: Folding) void {
    const max_row_length = 80;

    for (folding.folds) |fold| {
        foldPoints(folding.points, fold);
    }

    std.sort.sort([2]i32, folding.points, {}, pointLessThan);

    const points = folding.points;
    var minx = points[0][0];
    var maxx = points[0][0];
    var miny = points[0][1];
    var maxy = points[0][1];
    for (points) |p| {
        minx = std.math.min(minx, p[0]);
        maxx = std.math.max(maxx, p[0]);
        miny = std.math.min(miny, p[1]);
        maxy = std.math.max(maxy, p[1]);
    }
    if (maxx - minx > max_row_length) {
        @panic("The paper is too wide");
    }

    print("Part 2:", .{});

    var y: i32 = miny;
    var row = std.mem.zeroes([max_row_length]u8);
    var offset: usize = 0;
    while (y <= maxy) : (y += 1) {
        var x: i32 = minx;
        var row_offset: usize = 0;
        while (x <= maxx) : (x += 1) {
            row[row_offset] = ' ';
            for (points[offset..]) |p| {
                if (p[0] > x or p[1] > y) {
                    break;
                }
                if (p[0] == x and p[1] == y) {
                    row[row_offset] = '@';
                }
                offset += 1;
            }
            row_offset += 1;
        }
        print("{s}", .{row[0..row_offset]});
    }
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const part1_result = part1(try readInput(&arena));
    print("Part 1: {d}", .{part1_result});

    part2(try readInput(&arena));
}
