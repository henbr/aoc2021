const std = @import("std");
const Allocator = std.mem.Allocator;

pub const LineIterator = struct {
    buffer: []const u8,
    index: usize,

    const Self = @This();

    /// Returns the next line
    pub fn next(self: *Self) ?[]const u8 {
        if (self.index == self.buffer.len) {
            return null;
        }

        const start = self.index;
        while (
            self.index < self.buffer.len and
            self.buffer[self.index] != '\r' and
            self.buffer[self.index] != '\n'
        ) : (self.index += 1) {}
        const end = self.index;

        if (self.index < self.buffer.len and self.buffer[self.index] == '\r') {
            self.index += 1;
        }

        if (self.index < self.buffer.len and self.buffer[self.index] == '\n') {
            self.index += 1;
        }

        return self.buffer[start..end];
    }
};

pub fn iterate_lines(buffer: []const u8) LineIterator {
    return .{
        .index = 0,
        .buffer = buffer,
    };
}


pub const InputError = error{
    ReadFail,
};

pub const FileLineIterator = struct {
    allocator: *Allocator,
    buffer: []const u8,
    lines_it: LineIterator,

    const Self = @This();

    /// Returns the next line
    pub fn next(self: *Self) ?[]const u8 {
        return self.lines_it.next();
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.buffer);
    }
};

pub fn iterateLinesInFile(allocator: *Allocator, file_path: []const u8) anyerror!FileLineIterator {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buffer_size = 1024 * 1024;
    const buffer = try allocator.alloc(u8, buffer_size);
    const bytes_read = try file.readAll(buffer);
    if (bytes_read == buffer_size) {
        std.log.err("File too large :(", .{});
        return error.ReadFail;
    }
    const data = buffer[0..bytes_read];
    
    var lines_it = iterate_lines(data);

    return FileLineIterator {
        .allocator = allocator,
        .buffer = buffer,
        .lines_it = lines_it
    };
}

const writer = std.io.getStdOut().writer();
pub fn print(comptime format: []const u8, args: anytype) void {
    writer.print(format, args) catch return;
    _ = writer.write("\n") catch return;
}
