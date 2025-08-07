class HealthPack {
  float x, y;
  float radius = 30;
  boolean active = true;

  HealthPack() {
    x = random(60, width - 60);
    y = random(60, height - 60);
  }

  void display() {
    if (active) {
      noStroke();
      fill(0, 255, 0);  // bright green
      ellipse(x, y, radius * 2, radius * 2);
    }
  }

  boolean isCollected(Player p) {
    return active && dist(p.x, p.y, x, y) < radius + 20;
  }
}
