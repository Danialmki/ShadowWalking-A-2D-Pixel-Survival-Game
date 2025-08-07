class Boss {
  float x, y;
  float baseY;   
  float speed = 1.0;
  float hoverAmplitude = 10;     
  float hoverSpeed = 0.15;       
  float hoverAngle = 0;

  PImage bossImage;
  boolean visible = false;

  Boss(float startX, float startY) {
    x = startX;
    baseY = startY;
    y = startY;
    bossImage = loadImage("boss5.PNG");
    bossImage.resize(120, 140);
  }

  void update(Player p) {
    // Track player (x-direction only for better hover effect)
    float dx = p.x - x;
    float angle = atan2(0, dx);  // just track left/right
    x += cos(angle) * speed;

    // Hovering up and down
    hoverAngle += hoverSpeed;
    y = baseY + sin(hoverAngle) * hoverAmplitude;
  }

  void display() {
    if (visible) {
      imageMode(CENTER);
      image(bossImage, x, y);
    }
  }

  boolean isHit(Bullet b) {
    return dist(x, y, b.x, b.y) < 40;
  }

  boolean hitsPlayer(Player p) {
    return dist(x, y, p.x, p.y) < 50;
  }
}
