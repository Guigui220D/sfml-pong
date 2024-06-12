const std = @import("std");
const sfml = @import("sfml");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sfml_pong",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = mode,
    });

    const dep = b.dependency("sfml", .{}).module("sfml");
    exe.root_module.addImport("sfml", dep);
    // Necessary when the includes and libs are not available system wide, change the paths to what you want if that's the case
    // TODO: how to make that more convinient?
    dep.addIncludePath(b.path("csfml/include/"));
    exe.addLibraryPath(b.path("csfml/lib/msvc/"));
    sfml.link(exe);

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run.step);
}
