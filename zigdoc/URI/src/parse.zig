//
// $ zig version
// 0.14.0-dev.1166+bb7050106
//

const std = @import("std");
const Allocator = std.mem.Allocator;
const mem = std.mem;

pub const comp = struct {
    scheme: ?[]const u8,
    user: ?[]const u8,
    password: ?[]const u8,
    host: ?[]const u8,
    port: ?u16,
    path: ?[]const u8,
    query: ?[]const u8,
    fragment: ?[]const u8,
};

pub const parse_error = error {
    unexpected,
    invalidFormat,
    invalidPort,
};

fn scheme_char(char: u8) bool {
    return switch(char) {
        'A'...'Z', 'a'...'z', '0'...'9', '+', '-', '.' => true,
        else => false,
    };
}

fn auth_seperator(char: u8) bool {
    return switch(char) {
        '/', '?', '#' => true,
        else => false,
    };
}

// Reserved char are either gen-delims, or sub-delims
fn is_gen(char: u8) bool {
    return switch(char) {
        ':', ',', '?', '#', '[', ']', '@' => true,
        else => false,
    };
}

fn is_sub(char: u8) bool {
    return switch(char) {
        '!', '$', '&', '\'', '(', ')', '*', ',', ';', '=' => true,
        else => false,
    };
}

fn is_reserved(char: u8) bool {
    return is_gen(char) or is_sub(char);
}

// Unreserved char- alpha, digits, -, ., _, ~
fn is_unreserved(char: u8) bool {
    return switch(char) {
        'a'...'z', 'A'...'Z', '0'...'9', '-', '.', '_', '~' => true,
        else => false,
    };
}

fn is_path_sep(char: u8) bool {
    return switch(char) {
        '?', '#' => true,
        else => false,
    };
}

fn is_query_sep(char: u8) bool {
    return if(char == '#') true else false;
}

// URI encoding to replace reserve char with %XX code equivalent
pub fn escape(allocator: Allocator, input: []const u8) error{OutOfMemory}![]const u8 {

    var size: usize = 0;

    for (input) |char| {
        size += if(is_unreserved(char)) @intCast(1) else 3;
        // 3 - %XX
    }

    var out_string = try allocator.alloc(u8, size);
    var idx: usize = 0;

    for (input) |char| {
        if (is_unreserved(char)) {
            out_string[idx] = char; idx += 1;
        }else {
            var buff: [2]u8 = undefined;

            // pad with 0s to the left for width < 2
            _ = std.fmt.bufPrint(&buff, "{X:0>2}", .{char}) catch unreachable;
            out_string[idx] = '%';
            out_string[idx+1] = buff[0];
            out_string[idx+2] = buff[1];
            idx += 3;
        }
    }
    return out_string;
}

// un-escape all %XX segments if XX is valid hexnumber
pub fn unescape(allocator: Allocator, input: []const u8) error{OutOfMemory}![]const u8 {

    var size: usize = 0;
    var idx: usize = 0;

    while (idx < input.len) {
        if(input[idx] == '%') {
            idx += 1;
            if(idx + 2 <= input.len) {
                _ = std.fmt.parseInt(u8, input[idx..][0..2], 16) catch {
                    size += 3;
                    idx += 2;
                    continue;
                };

                size += 1;
                idx += 2;
            } 
        }else {
                idx += 1;
                size += 1;
            }
        }

        var output = try allocator.alloc(u8, size);
        var out: usize = 0;

        idx = 0;
        while(idx < input.len) {
            if (input[idx] == '%') {
                idx += 1;

                if (idx+2 <= input.len) {
                    const temp = std.fmt.parseInt(u8, input[idx..][0..2], 16) catch {
                        output[out] = input[idx]; out += 1; idx += 1;
                        output[out] = input[idx]; out += 1; idx += 1;

                        continue;
                    };
                    
                    output[out] = temp;
                    out += 1; idx += 2;
                } 
            }else {
                    output[out] = input[idx];
                    out += 1; idx += 1;
                }
        }

        return output;
}

pub const slice_reader = struct {
    const Self = @This();

    slice: []const u8,
    offset: usize= 0,

    fn get(self: *Self) ?u8 {
        if(self.offset >= self.slice.len) return null;
        self.offset += 1;
        return self.slice[self.offset-1];
    }

    fn peek(self: *Self) ?u8 {
        if(self.offset >= self.slice.len) return null;
        return self.slice[self.offset];
    }

    fn read_while(self: *Self, comptime pred: fn(u8) bool) []const u8{
        var end = self.offset;

        while(end < self.slice.len and pred(self.slice[end])) {
            end += 1;
        }
        
        const start = self.offset;
        self.offset = end;
        return self.slice[start..end];
    }

    fn read_until(self: *Self, comptime pred: fn(u8) bool) []const u8{
        var end = self.offset;

        while(end < self.slice.len and !pred(self.slice[end])) { end += 1; }
        const start = self.offset;
        self.offset = end;

        return self.slice[start..end];
    }
    
    fn read_untilEOF(self: *Self) []const u8 {
        const start = self.offset;
        self.offset = self.slice.len;

        return self.slice[start..];
    }

    fn peek_prefix(self: *Self, pref: []const u8) bool{
        if(self.offset + pref.len > self.slice.len) return false;

        return mem.eql(u8, self.slice[self.offset..][0..pref.len], pref);
    }
};


pub fn parse(input: []const u8) parse_error!comp {

    var uri = comp {
        .scheme = null,
        .user = null,
        .password = null,
        .host = null,
        .port = null,
        .path = "",
        .query = null,
        .fragment = null,
    };

    var reader = slice_reader { .slice = input };
    uri.scheme = reader.read_while(scheme_char);

    if (reader.get()) |char| {
        // after scheme seperator ':'
        if (char != ':') return error.unexpected; 
    }else return error.invalidFormat;
    
    if (reader.peek_prefix("//")) {
        std.debug.assert(reader.get().? == '/');
        std.debug.assert(reader.get().? == '/');
    
        const authority = reader.read_until(auth_seperator);
        if (authority.len == 0) return error.invalidFormat;

        var start_host: usize = 0;

        if (mem.indexOf(u8, authority, "@")) |idx| {
            start_host = idx + 1;
            const userinfo = authority[0..idx];

            if (mem.indexOf(u8, userinfo, ":")) |idx_| {
                uri.user = userinfo[0..idx_];

                if(idx_ < userinfo.len - 1) { uri.password = userinfo[idx_ + 1..];
                }
            } else {
                uri.user = userinfo; uri.password = null;
            }
        }

        var end_host: usize = authority.len;

        if (authority[start_host] == '[') // ipv6 address
        {
            end_host = mem.lastIndexOf(u8, authority, "]") orelse return error.invalidFormat;
            end_host += 1;

            if (mem.lastIndexOf(u8, authority, ":")) |idx| {
                if (idx >= end_host) // not part of ipv6
                {
                    end_host = min(end_host, idx);
                    uri.port = std.fmt.parseInt(u16, authority[idx+1..], 10) catch return error.invalidPort;
                }
            }
        } else if(mem.lastIndexOf(u8, authority, ":")) |idx| {
            if (idx >= start_host) // not part of userinfo
            {
                end_host = min(end_host, idx);
                uri.port = std.fmt.parseInt(u16, authority[idx+1..], 10) catch return error.invalidPort;
            }
        }

        uri.host = authority[start_host..end_host];
    }

    uri.path = reader.read_until(is_path_sep);

    if ( (reader.peek() orelse 0) == '?' ) // query comp
    {
        std.debug.assert(reader.get().? == '?');
        uri.query = reader.read_until(is_query_sep);
    }

    if( (reader.peek() orelse 0) == '#') // fragment comp
    {
        std.debug.assert(reader.get().? == '#');
        uri.fragment = reader.read_untilEOF();
    }

    return uri;
}


fn min(a: usize, b: usize) usize {
    return if(a < b) a else b;
}

