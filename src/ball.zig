const sf = struct {
    pub usingnamespace @import("sfml");
    pub usingnamespace system;
    pub usingnamespace graphics;
    pub usingnamespace audio;
};

usingnamespace @import("paddle.zig");
const Score = @import("score.zig");

pub const Ball = struct {

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
        
        var new = Ball {
            .rectangle = rect,
            .velocity = undefined,
            .paddles = paddles
        };

        new.reset();

        return new;
    }

    pub fn destroy(self: Ball) void {
        self.rectangle.destroy();
    }

    fn reset(self: *Ball) void {
        self.rectangle.setPosition(.{ .x = 400, .y = 300 });
        self.velocity = .{ .x = 400, .y = 300 };
    }

    pub fn update(self: *Ball, delta: f32) void {
        var prev_x = self.rectangle.getPosition().x;
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
        var ball_rect = sf.FloatRect.init(
            pos.x - 5,
            pos.y - 5,
            10,
            10
        );
        for (self.paddles) |p| {
            var p_size = p.rectangle.getSize();
            var p_pos = p.rectangle.getPosition();
            var paddle_rect = sf.FloatRect.init(
                p_pos.x - p_size.x / 2,
                p_pos.y - p_size.y / 2,
                p_size.x,
                p_size.y
            );
            if (ball_rect.intersects(paddle_rect) != null) {
                hit_sound.play();
                pos.x = prev_x;
                self.velocity.x *= -1;
                self.velocity = self.velocity.scale(1.02);
            }  
        }

        // Point scored
        if (pos.x < 0) {
            Score.right_score += 1;
            fail_sound.play();
            self.reset();
            pos = self.rectangle.getPosition();
        }
        if (pos.x > 800) {
            Score.left_score += 1;
            fail_sound.play();
            self.reset();
            pos = self.rectangle.getPosition();
        }

        self.rectangle.setPosition(pos);
    }

    rectangle: sf.RectangleShape,
    velocity: sf.Vector2f,
    paddles: []const Paddle
};
