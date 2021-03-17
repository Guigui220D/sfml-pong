const std = @import("std");
const sf = struct {
    pub usingnamespace @import("sfml");
    pub usingnamespace window;
    pub usingnamespace graphics;
    pub usingnamespace audio;
    pub usingnamespace system;
};

const Score = @import("score.zig");

usingnamespace @import("paddle.zig");
usingnamespace @import("ball.zig");

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    var window = try sf.RenderWindow.create(.{ .x = 800, .y = 600 }, 32, "SFML Pong in zig!");
    defer window.destroy();
    window.setFramerateLimit(60);

    var paddles = [_]Paddle {
        try Paddle.create(25, sf.keyboard.KeyCode.Z, sf.keyboard.KeyCode.S),
        try Paddle.create(775, sf.keyboard.KeyCode.Up, sf.keyboard.KeyCode.Down)
    };
    defer {
        for (paddles) |p|
            p.destroy();
    }
    var ball = try Ball.create(paddles[0..]);
    defer ball.destroy();

    var background_tex = try sf.Texture.createFromFile("background.png");
    defer background_tex.destroy();
    var background = try sf.Sprite.createFromTexture(background_tex);
    defer background.destroy();
    background.setOrigin(.{.x = 200, .y = 150});

    var font = try sf.Font.createFromFile("Clickuper.ttf");
    defer font.destroy();

    var score_text = try sf.Text.createWithText("0 : 0", font, 50);
    defer score_text.destroy();
    score_text.setFillColor(sf.Color.Cyan);
    score_text.setOutlineColor(sf.Color.Black);
    score_text.setOutlineThickness(2);

    var pause_text = try sf.Text.createWithText("Press space to play game", font, 50);
    defer pause_text.destroy();
    pause_text.setFillColor(sf.Color.Green);
    pause_text.setOutlineColor(sf.Color.Black);
    pause_text.setOutlineThickness(2);
    {
        var bounds = pause_text.getLocalBounds();
        var center = sf.Vector2f{
            .x = bounds.width / 2,
            .y = bounds.height / 2
        };
        std.debug.print("{}\n", .{bounds});
        //pause_text.setOrigin(center);
    }
    

    var clock = try sf.Clock.create();
    defer clock.destroy();

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
        //window.draw(score_text, null);
        //window.draw(pause_text, null);
        window.display();
    }
}
