const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const use_freetype = b.option(bool, "enable_freetype", "Build Freetype") orelse false;
    const enable_brotli = b.option(bool, "enable_freetpye_brotli", "Build brotli") orelse false;

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
        .enable_brotli = enable_brotli,
    });

    const lib = b.addStaticLibrary(.{
        .name = "harfbuzz",
        .root_source_file = .{ .path = "src/harfbuzz.cc" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    if (use_freetype) lib.linkLibrary(freetype_dep.artifact("freetype"));
    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "src" },
        .install_dir = .header,
        .install_subdir = "harfbuzz",
        .exclude_extensions = &.{".cc"},
    });
    b.installArtifact(lib);
}
