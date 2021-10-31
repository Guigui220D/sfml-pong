const sf = struct {
    pub usingnamespace @import("sfml");
    pub usingnamespace sf.graphics;
};

const Paddle = @This();

var texture: ?sf.Texture = null;

pub fn create(x_pos: f32, up: sf.window.keyboard.KeyCode, down: sf.window.keyboard.KeyCode) !Paddle {

    if (Paddle.texture == null) {
        texture = try sf.Texture.createFromFile("paddle.png");
    }

    var rect = try sf.RectangleShape.create(.{ .x = 10, .y = 100 });
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

pub fn destroy(self: *Paddle) void {
    self.rectangle.destroy();
}

pub fn update(self: *Paddle, delta: f32) void {
    if (sf.window.keyboard.isKeyPressed(self.up_key))
        self.rectangle.move(sf.system.Vector2f{ .x = 0, .y = delta * -800 });
    if (sf.window.keyboard.isKeyPressed(self.down_key))
        self.rectangle.move(sf.system.Vector2f{ .x = 0, .y = delta * 800 });
    
    var pos = self.rectangle.getPosition();
    if (pos.y < 50)
        pos.y = 50;
    if (pos.y > 550)
        pos.y = 550;
    self.rectangle.setPosition(pos);
}

up_key: sf.window.keyboard.KeyCode,
down_key: sf.window.keyboard.KeyCode,
rectangle: sf.RectangleShape