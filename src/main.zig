const std = @import("std");
const sf = struct {
    pub usingnamespace @import("sfml");
    pub usingnamespace sf.window;
    pub usingnamespace sf.graphics;
    pub usingnamespace sf.audio;
    pub usingnamespace sf.system;
};

const score = @import("score.zig");

const Paddle = @import("Paddle.zig");
const Ball = @import("Ball.zig");

pub fn main() anyerror!void {
    //const stdout = std.io.getStdOut().writer();

    var window = try sf.RenderWindow.create(.{ .x = 800, .y = 600 }, 32, "SFML Pong in zig!", sf.Style.defaultStyle);
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

    var score_text = try sf.Text.create();
    defer score_text.destroy();
    score_text.setFont(font);
    score_text.setCharacterSize(50);
    score_text.setFillColor(sf.Color.Cyan);
    score_text.setOutlineColor(sf.Color.Black);
    score_text.setOutlineThickness(2);
    score_text.setPosition(.{ .x = 400, .y = 30 });
    var score_buf: [32]u8 = undefined;

    var pause_text = try sf.Text.createWithText("Press space to play pong", font, 50);
    defer pause_text.destroy();
    pause_text.setFillColor(sf.Color.Green);
    pause_text.setOutlineColor(sf.Color.Black);
    pause_text.setOutlineThickness(2);
    pause_text.setPosition(.{ .x = 400, .y = 300 });
    {
        const bounds = pause_text.getGlobalBounds();
        const size = sf.Vector2f{ .x = bounds.width, .y = bounds.height };
        pause_text.setOrigin(size.scale(0.5));
    }
    

    var pause: bool = true;

    var clock = try sf.Clock.create();
    defer clock.destroy();

    while (window.isOpen()) {
        while (window.pollEvent()) |event| {
            switch (event) {
                .closed => window.close(),
                .keyReleased => |kev| {
                    if (kev.code == sf.keyboard.KeyCode.Space)
                        pause = !pause;
                },
                else => {}
            }
        }

        if (score.update_score) {
            pause = true;
            score.update_score = false;
            const str = try std.fmt.bufPrintZ(score_buf[0..], "{} : {}", .{ score.left_score, score.right_score });
            score_text.setString(str);
            const bounds = score_text.getGlobalBounds();
            const size = sf.Vector2f{ .x = bounds.width, .y = bounds.height };
            score_text.setOrigin(size.scale(0.5));
        }

        var delta = clock.restart().asSeconds();

        if (!pause) {
            for (paddles) |p|
                p.update(delta);

            ball.update(delta);
        }

        background.setPosition(ball.rectangle.getPosition().scale(0.1));

        window.clear(sf.Color.Black);
        window.draw(background, null);
        for (paddles) |p|
            window.draw(p.rectangle, null);
        window.draw(ball.rectangle, null);
        window.draw(score_text, null);
        if (pause)
        window.draw(pause_text, null);
        window.display();
    }
}
