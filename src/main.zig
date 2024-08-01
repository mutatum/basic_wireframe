const std = @import("std");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");

const InputError = error{
    Negative,
    TooLarge,
    MissingParameter,
};

fn validateDimensions(n: i32, m: i32) !void {
    if (n <= 0 or m <= 0) {
        return InputError.Negative;
    }

    if (n > 1000 or m > 1000) {
        return InputError.TooLarge;
    }
    return;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    var args = std.process.args();

    const call_name = args.next().?;
    const usage_str =
        \\ Usage: {s} <n> <m>
        \\ Where n and m are integers between 0 and 1000
        \\
    ;

    const n_str = args.next() orelse {
        try stderr.print(usage_str, .{call_name});
        return InputError.MissingParameter;
    };
    const n = try std.fmt.parseInt(i32, n_str, 10);

    const m_str = args.next() orelse {
        try stderr.print(usage_str, .{call_name});
        return InputError.MissingParameter;
    };
    const m = try std.fmt.parseInt(i32, m_str, 10);

    try validateDimensions(n, m);

    try stdout.print("call_name: {s}, n: {}, m:{}", .{ call_name, n, m });

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

    const width = 1000;
    const height = 800;
    const window = try glfw.Window.create(width, height, call_name, null);
    defer window.destroy();

    glfw.makeContextCurrent(window);

    const monitor = glfw.Monitor.getPrimary();
    const video_mode = try glfw.Monitor.getVideoMode(monitor.?);
    const monitor_width = video_mode.width;
    const monitor_height = video_mode.height;

    // Calculate the center position
    const window_x = @divTrunc(monitor_width - width, 2);
    const window_y = @divTrunc(monitor_height - height, 2);
    std.debug.print("{} {}", .{ window_x, window_y });

    // Set the window position
    window.setPos(window_x, window_y);

    try zopengl.loadCoreProfile(glfw.getProcAddress, gl_major, gl_minor);

    const gl = zopengl.bindings;

    glfw.swapInterval(1);

    while (!window.shouldClose()) {
        glfw.pollEvents();

        gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0, 0, 0, 1 });

        window.swapBuffers();
    }
}
