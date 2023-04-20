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

    var buf: [512]u8 = undefined;
    for (headers) |header| {
        lib.installHeader(
            std.fmt.bufPrint(&buf, "src/{s}", .{header}) catch
                @panic("header filename too long"),
            header,
        );
    }

    b.installArtifact(lib);
}

const headers = [_][]const u8{
    "hb-aat-layout.h",
    "hb-aat.h",
    "hb-blob.h",
    "hb-buffer.h",
    "hb-cairo.h",
    "hb-common.h",
    "hb-coretext.h",
    "hb-deprecated.h",
    "hb-directwrite.h",
    "hb-draw.h",
    "hb-face.h",
    "hb-font.h",
    "hb-ft.h",
    "hb-gdi.h",
    "hb-glib.h",
    "hb-gobject-structs.h",
    "hb-gobject.h",
    "hb-graphite2.h",
    "hb-icu.h",
    "hb-map.h",
    "hb-ot-color.h",
    "hb-ot-deprecated.h",
    "hb-ot-font.h",
    "hb-ot-layout.h",
    "hb-ot-math.h",
    "hb-ot-meta.h",
    "hb-ot-metrics.h",
    "hb-ot-name.h",
    "hb-ot-shape.h",
    "hb-ot-var.h",
    "hb-ot.h",
    "hb-paint.h",
    "hb-set.h",
    "hb-shape-plan.h",
    "hb-shape.h",
    "hb-style.h",
    "hb-subset-repacker.h",
    "hb-subset.h",
    "hb-unicode.h",
    "hb-uniscribe.h",
    "hb-version.h",
    "hb.h",
};
