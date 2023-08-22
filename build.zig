const std = @import("std");

pub var freetype_import_path: []const u8 = "freetype";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const enable_freetype = b.option(bool, "enable_freetype", "Build Freetype") orelse true;
    const use_system_zlib = b.option(bool, "freetype_use_system_zlib", "Use system zlib") orelse false;
    const enable_brotli = b.option(bool, "freetype_enable_brotli", "Build brotli") orelse true;

    // TODO: we cannot call b.dependency() inside of `pub fn build`
    // if we want users of the package to be able to make use of it.
    // See hexops/mach#902
    //
    // TODO: IMPORTANT: `include/` should also be entirely removed once we remove this hacky workaround
    _ = target;
    _ = optimize;
    _ = enable_freetype;
    _ = use_system_zlib;
    _ = enable_brotli;

    // const freetype_dep = b.dependency("freetype", .{
    //     .target = target,
    //     .optimize = optimize,
    //     .use_system_zlib = use_system_zlib,
    //     .enable_brotli = enable_brotli,
    // });
    // _ = freetype_dep;

    // const lib = b.addStaticLibrary(.{
    //     .name = "harfbuzz",
    //     .root_source_file = .{ .path = "src/harfbuzz.cc" },
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib.linkLibCpp();
    // lib.installHeadersDirectoryOptions(.{
    //     .source_dir = .{ .path = "src" },
    //     .install_dir = .header,
    //     .install_subdir = "harfbuzz",
    //     .exclude_extensions = &.{".cc"},
    // });
    // if (enable_freetype) {
    //     lib.defineCMacro("HAVE_FREETYPE", "1");
    //     lib.linkLibrary(@import("freetype").lib(b, optimize, target));
    //     @import("freetype").addPaths(lib);
    // }
    // b.installArtifact(lib);
}

// TODO: remove this once hexops/mach#902 is fixed.
pub fn lib(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    target: std.zig.CrossTarget,
) *std.Build.Step.Compile {
    const enable_freetype = true;
    const use_system_zlib = false;
    const enable_brotli = true;

    const freetype_dep = b.dependency(freetype_import_path, .{
        .target = target,
        .optimize = optimize,
        .use_system_zlib = use_system_zlib,
        .enable_brotli = enable_brotli,
    });
    _ = freetype_dep;

    const l = b.addStaticLibrary(.{
        .name = "harfbuzz",
        .root_source_file = .{ .path = sdkPath("/src/harfbuzz.cc") },
        .target = target,
        .optimize = optimize,
    });
    l.linkLibCpp();
    // l.installHeadersDirectoryOptions(.{
    //     .source_dir = .{ .path = sdkPath("/src") },
    //     .install_dir = .header,
    //     .install_subdir = "harfbuzz",
    //     .exclude_extensions = &.{".cc"},
    // });
    if (enable_freetype) {
        l.defineCMacro("HAVE_FREETYPE", "1");
        l.linkLibrary(@import("freetype").lib(b, optimize, target));
        @import("freetype").addPaths(l);
    }
    // b.installArtifact(l);
    return l;
}

pub fn addPaths(step: *std.build.CompileStep) void {
    step.addIncludePath(.{ .path = sdkPath("/include") });
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
