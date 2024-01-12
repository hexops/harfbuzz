const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const enable_freetype = b.option(bool, "enable_freetype", "Build Freetype") orelse true;
    const use_system_zlib = b.option(bool, "freetype_use_system_zlib", "Use system zlib") orelse false;
    const enable_brotli = b.option(bool, "freetype_enable_brotli", "Build brotli") orelse true;

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
        .use_system_zlib = use_system_zlib,
        .enable_brotli = enable_brotli,
    });
    _ = freetype_dep;

    const lib = b.addStaticLibrary(.{
        .name = "harfbuzz",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile(.{ .file = .{ .path = "src/harfbuzz.cc" } });
    lib.linkLibCpp();
    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "src" },
        .install_dir = .header,
        .install_subdir = "harfbuzz",
        .exclude_extensions = &.{".cc"},
    });
    if (enable_freetype) {
        lib.defineCMacro("HAVE_FREETYPE", "1");
        lib.linkLibrary(b.dependency("freetype", .{
            .target = target,
            .optimize = optimize,
        }).artifact("freetype"));
    }
    b.installArtifact(lib);
}
