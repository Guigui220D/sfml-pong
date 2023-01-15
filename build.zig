const Builder = @import("std").build.Builder;
const sfml = @import("zig-sfml-wrapper/build.zig");

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("sfml", "src/main.zig");
    exe.addPackage(sfml.pkg("sfml"));
    sfml.link(exe);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_step = b.step("run", "Run pong");
    run_step.dependOn(&exe.run().step);
}
