class Player {
  float x, y;
  float vy = 0;
  float gravity = 0.9;
  float jumpStrength = 12;
  boolean isJumping = false;
  int health = 100;
  int damageCooldown = 0; 

  PImage sprite;

  Player() {
    x = width / 3;
    y = height - 50;
    sprite = loadImage("player.png");
    sprite.resize(82, 82);
  }

void update() {
  vy += gravity;
  y += vy;

  if (y > height - 50) {
    y = height - 50;
    vy = 0;
    isJumping = false;
  }

  // Background auto-scroll
  bgX1 -= scrollSpeed;
  if (bgX1 <= -bgImage.width) {
    bgX1 += bgImage.width;
  }

  // Animate between 2 frames
  frameCounter++;
  if (frameCounter >= frameDelay) {
    currentFrame = (currentFrame + 1) % walkFrames.length;  // Loops 0–1–0–1
    frameCounter = 0;
  }

  if (damageCooldown > 0) damageCooldown--;
}

  void jump() {
    if (!isJumping) {
      vy = jumpStrength;
      isJumping = true;
    }
  }

  void takeDamage() {
    if (damageCooldown == 0) {
      health -= 25;
      health = max(0, health);
      damageCooldown = 20;
    }
        if (damageSound != null) {
      damageSound.trigger();
    }
  }

  void display() {
    imageMode(CENTER);
    image(walkFrames[currentFrame], x, y);
  }
}
