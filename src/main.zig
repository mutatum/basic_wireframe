const std = @import("std");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");

const program_name = "basic_wireframe";

const DimensionError = error{
    Negative,
    TooLarge,
};

fn validateDimensions(n: i32, m: i32) !void {
    if (n <= 0 or m <= 0) {
        return DimensionError.Dimension;
    }

    if (n > 1000 or m > 1000) {
        return DimensionError.TooLarge;
    }
}

pub fn main() !void {
    const args = std.process.args;
    const stdout = std.io.getStdOut().writer();

    if (args.len < 3) {
        stdout.print("Usage: {} <n> <m>\n", .{args[0]});
        return;
    }

    const n = std.fmt.parseInt(i32, args[1], 10);
    const m = std.fmt.parseInt(i32, args[2], 10);

    validateDimensions(n, m);

    glfw.init() catch |glfw_init_error| {
        std.debug.print("GLFW initialization error: {}\n", .{glfw_init_error});
        return;
    };
    defer glfw.terminate();

    const gl_major = 4;
    const gl_minor = 0;
    glfw.windowHintTyped(.context_version_major, gl_major);
    glfw.windowHintTyped(.context_version_minor, gl_minor);
    glfw.windowHintTyped(.opengl_profile, .opengl_core_profile);
    glfw.windowHintTyped(.opengl_forward_compat, true);
    glfw.windowHintTyped(.client_api, .opengl_api);
    glfw.windowHintTyped(.doublebuffer, true);

    const window = try glfw.Window.create(600, 600, program_name, null);
    defer window.destroy();

    glfw.makeContextCurrent(window);

    try zopengl.loadCoreProfile(glfw.getProcAddress, gl_major, gl_minor);

    const gl = zopengl.bindings;

    glfw.swapInterval(1);

    while (!window.shouldClose()) {
        glfw.pollEvents();

        gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0, 0, 0, 1 });

        window.swapBuffers();
    }
}
