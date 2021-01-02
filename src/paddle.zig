const sf = @import("sfml");

pub const Paddle = struct {

    var texture: ?sf.Texture = null;

    pub fn init(x_pos: f32, up: sf.Keyboard.KeyCode, down: sf.Keyboard.KeyCode) !Paddle {

        if (Paddle.texture == null) {
            texture = try sf.Texture.initFromFile("paddle.png");
        }

        var rect = try sf.RectangleShape.init(.{ .x = 10, .y = 100 });
        rect.setOrigin(.{ .x = 5, .y = 50 });
        rect.setPosition(.{ .x = x_pos, .y = 300 });
        rect.setFillColor(sf.Color.White);
        rect.setTexture(Paddle.texture.?);

        return Paddle {
            .up_key = up,
            .down_key = down,
            .rectangle = rect
        };
    }

    pub fn deinit(self: Paddle) void {
        self.rectangle.deinit();
    }

    pub fn update(self: Paddle, delta: f32) void {
        if (sf.Keyboard.isKeyPressed(self.up_key))
            self.rectangle.move(sf.Vector2f{ .x = 0, .y = delta * -800 });
        if (sf.Keyboard.isKeyPressed(self.down_key))
            self.rectangle.move(sf.Vector2f{ .x = 0, .y = delta * 800 });
        
        var pos = self.rectangle.getPosition();
        if (pos.y < 50)
            pos.y = 50;
        if (pos.y > 550)
            pos.y = 550;
        self.rectangle.setPosition(pos);
    }

    up_key: sf.Keyboard.KeyCode,
    down_key: sf.Keyboard.KeyCode,
    rectangle: sf.RectangleShape
};
