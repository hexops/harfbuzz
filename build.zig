const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const enable_freetype = b.option(bool, "enable_freetype", "Build Freetype") orelse true;
    const use_system_zlib = b.option(bool, "freetype_use_system_zlib", "Use system zlib") orelse false;
    const enable_brotli = b.option(bool, "freetype_enable_brotli", "Build brotli") orelse true;

    const lib = b.addStaticLibrary(.{
        .name = "harfbuzz",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile(.{ .file = b.path("src/harfbuzz.cc") });
    lib.linkLibCpp();
    lib.installHeadersDirectory(b.path("src"), "harfbuzz", .{
        .exclude_extensions = &.{".cc"},
    });
    if (enable_freetype) {
        lib.root_module.addCMacro("HAVE_FREETYPE", "1");

        if (b.lazyDependency("freetype", .{
            .target = target,
            .optimize = optimize,
            .use_system_zlib = use_system_zlib,
            .enable_brotli = enable_brotli,
        })) |dep| {
            lib.linkLibrary(dep.artifact("freetype"));
        }
    }
    b.installArtifact(lib);
}
