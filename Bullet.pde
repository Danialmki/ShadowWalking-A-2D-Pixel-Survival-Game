class Bullet {
  float x, y;
  float dx, dy;
  float speed;

  Bullet(float startX, float startY, float targetX, float targetY, float speed) {
    this.x = startX;
    this.y = startY;
    this.speed = speed;

    float angle = atan2(targetY - startY, targetX - startX);
    dx = cos(angle) * speed;
    dy = sin(angle) * speed;
  }

  void update() {
    x += dx;
    y += dy;
  }

  void display() {
    fill(255);
    ellipse(x, y, 8, 8);
  }

  boolean offScreen() {
    return x > width || x < 0 || y > height || y < 0;
  }
}
