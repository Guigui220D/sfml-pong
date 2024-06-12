const sf = struct {
    const sfml = @import("sfml");
    pub usingnamespace sfml;
    pub usingnamespace sfml.graphics;
    pub usingnamespace sfml.audio;
    pub usingnamespace sfml.system;
};

const Paddle = @import("Paddle.zig");
const Score = @import("score.zig");

const Ball = @This();

var texture: ?sf.Texture = null;
var fail_sound_buffer: sf.SoundBuffer = undefined;
var fail_sound: sf.Sound = undefined;
var hit_sound_buffer: sf.SoundBuffer = undefined;
var hit_sound: sf.Sound = undefined;

pub fn create(paddles: []const Paddle) !Ball {
    if (Ball.texture == null) {
        texture = try sf.Texture.createFromFile("ball.png");

        fail_sound_buffer = try sf.SoundBuffer.createFromFile("fail.wav");
        hit_sound_buffer = try sf.SoundBuffer.createFromFile("click.wav");

        fail_sound = try sf.Sound.createFromBuffer(fail_sound_buffer);
        hit_sound = try sf.Sound.createFromBuffer(hit_sound_buffer);
    }

    var rect = try sf.RectangleShape.create(.{ .x = 20, .y = 20 });
    rect.setOrigin(.{ .x = 10, .y = 10 });
    rect.setFillColor(sf.Color.White);
    rect.setTexture(Ball.texture.?);

    var new = Ball{ .rectangle = rect, .velocity = undefined, .paddles = paddles };

    new.reset();

    return new;
}

pub fn destroy(self: *Ball) void {
    self.rectangle.destroy();
}

fn reset(self: *Ball) void {
    self.rectangle.setPosition(.{ .x = 400, .y = 300 });
    self.velocity = .{ .x = 400, .y = 300 };
}

pub fn update(self: *Ball, delta: f32) void {
    const prev_x = self.rectangle.getPosition().x;
    self.rectangle.move(self.velocity.scale(delta));

    var pos = self.rectangle.getPosition();
    // Wall collisions
    if (pos.y < 5) {
        pos.y = 5;
        self.velocity.y *= -1;
    }
    if (pos.y > 595) {
        pos.y = 595;
        self.velocity.y *= -1;
    }
    // Paddle collisions
    for (self.paddles) |p| {
        if (self.rectangle.getGlobalBounds().intersects(p.rectangle.getGlobalBounds())) |_| {
            hit_sound.play();
            pos.x = prev_x;
            self.velocity.x *= -1.04;
        }
    }

    // Point scored
    if (pos.x < 0) {
        Score.right_score += 1;
        Score.update_score = true;
        fail_sound.play();
        self.reset();
        pos = self.rectangle.getPosition();
    }
    if (pos.x > 800) {
        Score.left_score += 1;
        Score.update_score = true;
        fail_sound.play();
        self.reset();
        pos = self.rectangle.getPosition();
    }

    self.rectangle.setPosition(pos);
}

rectangle: sf.RectangleShape,
velocity: sf.Vector2f,
paddles: []const Paddle
