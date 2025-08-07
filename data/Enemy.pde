class Enemy {
  float x, y;
  float speed = 2.5;
  boolean visible = false;
  PImage sprite;

  Enemy(float x, float y) {
    this.x = x;
    this.y = y;
    sprite = loadImage("enemy.png"); // Make sure this image is in your /data folder
    sprite.resize(72, 72);
  }

  void update() {
    PVector enemyPos = new PVector(x, y);
    PVector playerPos = new PVector(player.x, player.y);

    PVector direction = PVector.sub(playerPos, enemyPos);
    direction.normalize();
    direction.mult(speed);

    x += direction.x;
    y += direction.y;
  }

  void display() {
    if (!visible) return;
    imageMode(CENTER);
    image(sprite, x, y);
  }

  boolean hits(Bullet b) {
    return dist(x, y, b.x, b.y) < 20;
  }
}
