const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const freetype = b.option(bool, "freetype", "use freetype") orelse true;
    // TODO: somehow let freetype choose the default value here?
    const freetype_brotli = b.option(bool, "freetype_brotli", "Makes the freetype dependency use brotli") orelse false;

    const lib = b.addStaticLibrary(.{
        .name = "harfbuzz",
        .root_source_file = .{ .path = "src/harfbuzz.cc" },
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibCpp();

    if (freetype) {
        lib.linkLibrary(b.dependency("freetype", .{
            .target = target,
            .optimize = optimize,
            .brotli = freetype_brotli,
        }).artifact("freetype"));
    }

    lib.install();
}
