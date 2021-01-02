const std = @import("std");
const sf =  @import("sfml");

const Score = @import("score.zig");

usingnamespace @import("paddle.zig");
usingnamespace @import("ball.zig");

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    var window = try sf.RenderWindow.init(.{ .x = 800, .y = 600 }, 32, "SFML Pong in zig!");
    defer window.deinit();
    window.setFramerateLimit(60);

    var paddles = [_]Paddle {
        try Paddle.init(25, sf.Keyboard.KeyCode.Z, sf.Keyboard.KeyCode.S),
        try Paddle.init(775, sf.Keyboard.KeyCode.Up, sf.Keyboard.KeyCode.Down)
    };
    defer {
        for (paddles) |p|
            p.deinit();
    }
    var ball = try Ball.init(paddles[0..]);
    defer ball.deinit();

    var background_tex = try sf.Texture.initFromFile("background.png");
    defer background_tex.deinit();
    var background = try sf.Sprite.initFromTexture(background_tex);
    defer background.deinit();
    background.setOrigin(.{.x = 200, .y = 150});

    var clock = try sf.Clock.init();
    defer clock.deinit();

    while (window.isOpen()) {
        while (window.pollEvent()) |event| {
            if (event == .closed) {
                stdout.print("Left Player: {} points\nRight Player: {} points\n", .{ Score.left_score, Score.right_score }) catch {};
                window.close();
            }
        }

        var delta = clock.restart().asSeconds();

        for (paddles) |p|
            p.update(delta);

        ball.update(delta);

        background.setPosition(ball.rectangle.getPosition().scale(0.1));

        window.clear(sf.Color.Black);
        window.draw(background, null);
        for (paddles) |p|
            window.draw(p.rectangle, null);
        window.draw(ball.rectangle, null);
        window.display();
    }
}
