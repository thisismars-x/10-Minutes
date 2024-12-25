
const std = @import("std");
const uri_ = @import("parse.zig");

const parse = uri_.parse;
const escape = uri_.escape;
const unescape = uri_.unescape;
const comp = uri_.comp;

// usingnamespace @import("parse.zig"); <-- not working as intended

test "scheme" {
        try std.testing.expectEqualSlices(u8, "http", (try parse("http:_")).scheme.?);
        try std.testing.expectEqualSlices(u8, "scheme-mee", (try parse("scheme-mee:_")).scheme.?);
        try std.testing.expectEqualSlices(u8, "a.b.c", (try parse("a.b.c:_")).scheme.?);
        try std.testing.expectEqualSlices(u8, "ab+", (try parse("ab+:_")).scheme.?);
        try std.testing.expectEqualSlices(u8, "X+++", (try parse("X+++:_")).scheme.?);
        try std.testing.expectEqualSlices(u8, "Y+-.", (try parse("Y+-.:_")).scheme.?);
}

test "authority" {
    try std.testing.expectEqualSlices(u8, "hostname", (try parse("scheme://hostname")).host.?);

    try std.testing.expectEqualSlices(u8, "hostname", (try parse("scheme://userinfo@hostname")).host.?);
    try std.testing.expectEqualSlices(u8, "userinfo", (try parse("scheme://userinfo@hostname")).user.?);
    try std.testing.expectEqual(@as(?[]const u8, null), (try parse("scheme://userinfo@hostname")).password);

    try std.testing.expectEqualSlices(u8, "hostname", (try parse("scheme://user:password@hostname")).host.?);
    try std.testing.expectEqualSlices(u8, "user", (try parse("scheme://user:password@hostname")).user.?);
    try std.testing.expectEqualSlices(u8, "password", (try parse("scheme://user:password@hostname")).password.?);

    try std.testing.expectEqualSlices(u8, "hostname", (try parse("scheme://hostname:0")).host.?);
    try std.testing.expectEqual(@as(u16, 1234), (try parse("scheme://hostname:1234")).port.?);

    try std.testing.expectEqualSlices(u8, "hostname", (try parse("scheme://userinfo@hostname:1234")).host.?);
    try std.testing.expectEqual(@as(u16, 1234), (try parse("scheme://userinfo@hostname:1234")).port.?);
    try std.testing.expectEqualSlices(u8, "userinfo", (try parse("scheme://userinfo@hostname:1234")).user.?);
    try std.testing.expectEqual(@as(?[]const u8, null), (try parse("scheme://userinfo@hostname:1234")).password);

    try std.testing.expectEqualSlices(u8, "hostname", (try parse("scheme://user:password@hostname:1234")).host.?);
    try std.testing.expectEqual(@as(u16, 1234), (try parse("scheme://user:password@hostname:1234")).port.?);
    try std.testing.expectEqualSlices(u8, "user", (try parse("scheme://user:password@hostname:1234")).user.?);
    try std.testing.expectEqualSlices(u8, "password", (try parse("scheme://user:password@hostname:1234")).password.?);
}

test "authority.password" {
    try std.testing.expectEqualSlices(u8, "username", (try parse("scheme://username@a")).user.?);
    try std.testing.expectEqual(@as(?[]const u8, null), (try parse("scheme://username@a")).password);

    try std.testing.expectEqualSlices(u8, "username", (try parse("scheme://username:@a")).user.?);
    try std.testing.expectEqual(@as(?[]const u8, null), (try parse("scheme://username:@a")).password);

    try std.testing.expectEqualSlices(u8, "username", (try parse("scheme://username:password@a")).user.?);
    try std.testing.expectEqualSlices(u8, "password", (try parse("scheme://username:password@a")).password.?);

    try std.testing.expectEqualSlices(u8, "username", (try parse("scheme://username::@a")).user.?);
    try std.testing.expectEqualSlices(u8, ":", (try parse("scheme://username::@a")).password.?);
}

fn testAuthorityHost(comptime hostlist: anytype) !void {
    inline for (hostlist) |hostname| {
        try std.testing.expectEqualSlices(u8, hostname, (try parse("scheme://" ++ hostname)).host.?);
    }
}

test "authority.dns-names" {
    try testAuthorityHost(.{
        "a",
        "a.b",
        "example.com",
        "www.example.com",
        "example.org.",
        "www.example.org.",
        "xn--nw2a.xn--j6w193g", // internationalization!
        "fe80--1ff-fe23-4567-890as3.ipv6-literal.net",
    });
    // still allowed…
}

test "authority.IPv4" {
    try testAuthorityHost(.{
        "127.0.0.1",
        "255.255.255.255",
        "0.0.0.0",
        "8.8.8.8",
        "1.2.3.4",
        "192.168.0.1",
        "10.42.0.0",
    });
}

test "authority.IPv6" {
    try testAuthorityHost(.{
        "[2001:db8:0:0:0:0:2:1]",
        "[2001:db8::2:1]",
        "[2001:db8:0000:1:1:1:1:1]",
        "[2001:db8:0:1:1:1:1:1]",
        "[0:0:0:0:0:0:0:0]",
        "[0:0:0:0:0:0:0:1]",
        "[::1]",
        "[::]",
        "[2001:db8:85a3:8d3:1319:8a2e:370:7348]",
        "[fe80::1ff:fe23:4567:890a%25eth2]",
        "[fe80::1ff:fe23:4567:890a]",
        "[fe80::1ff:fe23:4567:890a%253]",
        "[fe80:3::1ff:fe23:4567:890a]",
    });
}

test "RFC example 1" {
    const uri = "foo://example.com:8042/over/there?name=ferret#nose";
    try std.testing.expectEqual(comp{
        .scheme = uri[0..3],
        .user = null,
        .password = null,
        .host = uri[6..17],
        .port = 8042,
        .path = uri[22..33],
        .query = uri[34..45],
        .fragment = uri[46..50],
    }, try parse(uri));
}

test "RFX example 2" {
    const uri = "urn:example:animal:ferret:nose";
    try std.testing.expectEqual(comp{
        .scheme = uri[0..3],
        .user = null,
        .password = null,
        .host = null,
        .port = null,
        .path = uri[4..],
        .query = null,
        .fragment = null,
    }, try parse(uri));
}

// source:
// https://en.wikipedia.org/wiki/Uniform_Resource_Identifier#Examples
test "Examples from wikipedia" {
    // these should all parse
    const list = [_][]const u8{
        "https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top",
        "ldap://[2001:db8::7]/c=GB?objectClass?one",
        "mailto:John.Doe@example.com",
        "news:comp.infosystems.www.servers.unix",
        "tel:+1-816-555-1212",
        "telnet://192.0.2.16:80/",
        "urn:oasis:names:specification:docbook:dtd:xml:4.1.2",
        "http://a/b/c/d;p?q",
    };
    for (list) |uri| {
        _ = try parse(uri);
    }
}

// source:
// https://tools.ietf.org/html/rfc3986#section-5.4.1
test "Examples from RFC3986" {
    // these should all parse
    const list = [_][]const u8{
        "http://a/b/c/g",
        "http://a/b/c/g",
        "http://a/b/c/g/",
        "http://a/g",
        "http://g",
        "http://a/b/c/d;p?y",
        "http://a/b/c/g?y",
        "http://a/b/c/d;p?q#s",
        "http://a/b/c/g#s",
        "http://a/b/c/g?y#s",
        "http://a/b/c/;x",
        "http://a/b/c/g;x",
        "http://a/b/c/g;x?y#s",
        "http://a/b/c/d;p?q",
        "http://a/b/c/",
        "http://a/b/c/",
        "http://a/b/",
        "http://a/b/",
        "http://a/b/g",
        "http://a/",
        "http://a/",
        "http://a/g",
    };
    for (list) |uri| {
        _ = try parse(uri);
    }
}

test "Special test" {
    // This is for all of you code readers ♥
    _ = try parse("https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=youtu.be&t=0");
}

test "URI escaping" {
    const input = "\\ö/ äöß ~~.adas-https://canvas:123/#ads&&sad";
    const expected = "%5C%C3%B6%2F%20%C3%A4%C3%B6%C3%9F%20~~.adas-https%3A%2F%2Fcanvas%3A123%2F%23ads%26%26sad";

    const actual = try escape(std.testing.allocator, input);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualSlices(u8, expected, actual);
}

test "URI unescaping" {
    const input = "%5C%C3%B6%2F%20%C3%A4%C3%B6%C3%9F%20~~.adas-https%3A%2F%2Fcanvas%3A123%2F%23ads%26%26sad";
    const expected = "\\ö/ äöß ~~.adas-https://canvas:123/#ads&&sad";

    const actual = try unescape(std.testing.allocator, input);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualSlices(u8, expected, actual);
}