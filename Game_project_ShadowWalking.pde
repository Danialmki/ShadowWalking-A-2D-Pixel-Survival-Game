Player player;
String descriptionText = "You play as a lone survivor with a flashlight.\n"
                       + "Enemies approach from all directions.\n"
                       + "Use your flashlight to reveal them and shoot to survive.\n"
                       + "If you survive all 5 enemies, you win.\n"
                       + "If you're hit too many times, you lose.";
                       
String startText = "Use your flashlight to survive the undead.";                      
ArrayList<Enemy> enemies;
ArrayList<Bullet> bullets;
HealthPack healthPack;
int healthPackTimer = 0;         // controls when to spawn
int healthPackInterval = 60;    // every ~10 seconds (60fps * 10)
PImage trophyImage;
PImage[] walkFrames = new PImage[2];
int currentFrame = 0;
int frameCounter = 0;
int frameDelay = 8;
int shootCooldown = 0;         
int shootCooldownTime = 30;   // shoot cool down
boolean isReloading = false;

boolean flashlightOn = false;
boolean gameOver = false;
boolean gameWon = false;
boolean showStartScreen = true;
boolean showDescription = false;
boolean levelWon = false;
boolean bossActive = false;
Boss boss;
int bossHealth = 1;
int bossMaxHealth = 1;

int currentLevel = 1;
int totalLevels = 3;

PImage characterImage;
PFont titleFont, bodyFont;

PImage bgImage;
float bgX1 = 0;
float bgX2;
float scrollSpeed = 2;

float flashlightAngle = 0;
int enemiesSpawned = 0;
int enemiesToSpawn = 5;

import ddf.minim.*;
Minim minim;
AudioPlayer bgMusic;
AudioSample gunshotSound;
AudioPlayer flashlightOnSound;
AudioSample damageSound;
AudioSample enemyHitSound;

void setup() {
          // Initialize to null at start
healthPack = new HealthPack();  // 🔥 FORCE IT TO SPAWN IMMEDIATELY 
  bossMaxHealth = 5;
  bossHealth = bossMaxHealth;
  size(800, 400);
  walkFrames[0] = loadImage("walk1.PNG");
  walkFrames[1] = loadImage("walk3.PNG");
  for (int i = 0; i < walkFrames.length; i++) walkFrames[i].resize(80, 80);

  minim = new Minim(this);
  bgMusic = minim.loadFile("spooky-whistle-382121.mp3", 2048);
  bgMusic.loop();
  gunshotSound = minim.loadSample("gunshot.mp3", 512);
  flashlightOnSound = minim.loadFile("flashlight.mp3");
  damageSound = minim.loadSample("ouch.mp3", 512);
  enemyHitSound = minim.loadSample("enemy_hit.mp3", 512);

  titleFont = createFont("Arial", 36);
  bodyFont = createFont("Arial", 16);
  characterImage = walkFrames[0];
  trophyImage = loadImage("trophy.png");  
  trophyImage.resize(120, 120);  
  bgImage = loadImage("bg.png");
  bgImage.resize(800, 800);
  bgX2 = bgImage.width;

  player = new Player();
  enemies = new ArrayList<Enemy>();
  bullets = new ArrayList<Bullet>();
  currentLevel = 1;
  loadLevel(currentLevel);

}

void draw() {
  
if (healthPack != null) {
  healthPack.display();
  if (healthPack.isCollected(player)) {
    player.health = 100;
    healthPack = null;
    println("💉 Healed!");
  }
}
  if (shootCooldown > 0) shootCooldown--;
  if (showStartScreen) {
    if (showDescription) drawDescriptionScreen();
    else drawStartScreen();
    return;
  }

  background(0);

  if (!levelWon && enemiesSpawned == enemiesToSpawn && enemies.size() == 0 && player.health > 0 && (!bossActive || boss == null)) {
    levelWon = true;
  }

  if (levelWon) {
    fill(0, 255, 0);
    textSize(24);
    textAlign(CENTER);
    text("Level " + currentLevel + " Complete!\nClick to continue", width / 2, height / 2);
    return;
  }

  if (!gameWon && player.health <= 0) gameOver = true;
  if (gameOver) { showGameOver(); return; }
  if (gameWon) { showVictoryScreen(); return; }

  for (int i = -1; i <= width / bgImage.width + 1; i++) {
    image(bgImage, bgX1 + i * bgImage.width, 0);
  }

  drawHealthBar();
  flashlightAngle = atan2(mouseY - player.y, mouseX - player.x);

  ArrayList<PVector> flashlightArea = new ArrayList<PVector>();
  if (flashlightOn) flashlightArea = drawFlashlightCone();

  player.update();
  player.display();

  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.display();
    if (b.offScreen()) bullets.remove(i);
  }

  spawnEnemies();

  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    e.visible = flashlightOn && isInFlashlightCone(e, flashlightArea);
    e.display();

    if (e.visible) {
      for (int j = bullets.size() - 1; j >= 0; j--) {
        if (e.hits(bullets.get(j))) {
           if (enemyHitSound != null) enemyHitSound.trigger();
          enemies.remove(i);
          bullets.remove(j);
          break;
        }
      }
    }

    if (dist(e.x, e.y, player.x, player.y) < 20) {
      player.takeDamage();
      if (damageSound != null) damageSound.trigger();  // 🔊 Play sound here
      enemies.remove(i);
    }
  }

  if (bossActive && boss != null) {
    boss.visible = flashlightOn && isInFlashlightCone(boss, flashlightArea);
    boss.update(player);
    boss.display();

    for (int i = bullets.size() - 1; i >= 0; i--) {
      if (boss.isHit(bullets.get(i))) {
        bossHealth--;
        bullets.remove(i);
        if (bossHealth <= 0) {
          bossActive = false;
          gameWon = true;
        }
        break;
      }
    }

    if (boss.hitsPlayer(player)) {
      gameOver = true;
    }

    drawBossHealthBar();
  }

  println("Health: " + player.health);
  println("Enemies left: " + enemies.size());
  println("Spawned: " + enemiesSpawned);
}

void drawBossHealthBar() {
  float barWidth = 200;
  float barHeight = 20;
  float x = width - barWidth - 20;
  float y = 50;

  float percent = bossHealth / float(bossMaxHealth);
  float currentWidth = barWidth * percent;

  // Background of the bar (gray)
  fill(100);
  rect(x, y, barWidth, barHeight);

  // Foreground: colored health
  fill(lerpColor(color(255, 0, 0), color(0, 255, 0), percent));  // red → green
  rect(x, y, currentWidth, barHeight);

  // Border
  noFill();
  stroke(255);
  rect(x, y, barWidth, barHeight);
  noStroke();

  // Label
  fill(255);
  textSize(14);
  textAlign(CENTER);
  text("Boss HP", x + barWidth / 2, y - 5);
}




void mousePressed() {
  float offsetX = 30;  // Horizontal offset (e.g., gun at right side)
float offsetY = 10;
if (!gameOver && !gameWon && mouseButton == LEFT && shootCooldown == 0) {
  float angle = atan2(mouseY - player.y, mouseX - player.x);
  float offset = 30;
  float bulletX = player.x + cos(angle) * offset;
  float bulletY = player.y + sin(angle) * offset;
  float offsetDistance = 30;  // distance in the direction of the flashlight

float bulletStartX = player.x + cos(angle) * offsetDistance;
float bulletStartY = player.y + sin(angle) * offsetDistance;
  bullets.add(new Bullet(bulletStartX, bulletStartY, mouseX, mouseY, 20));
  gunshotSound.trigger();
  shootCooldown = shootCooldownTime;  // start cooldown
}
  if (levelWon) {
    if (currentLevel < totalLevels) {
      currentLevel++;
      loadLevel(currentLevel);
      levelWon = false;
    } else {
      gameWon = true;
      levelWon = false;
    }
    return;
  }


  if (showStartScreen) {
    if (showDescription) {
      if (mouseX > width / 2 - 60 && mouseX < width / 2 + 60 && mouseY > 350 - 20 && mouseY < 350 + 20)
        showDescription = false;
    } else {
      if (mouseX > width / 2 - 80 && mouseX < width / 2 + 80 && mouseY > 290 - 20 && mouseY < 290 + 20)
        showStartScreen = false;
      if (mouseX > width / 2 - 80 && mouseX < width / 2 + 80 && mouseY > 350 - 20 && mouseY < 350 + 20)
        showDescription = true;
    }
    return;
  }
    if (levelWon) {
    if (currentLevel < totalLevels) {
      currentLevel++;
      loadLevel(currentLevel);  
      levelWon = false;
    } else {
      gameWon = true;
      levelWon = false;
    }
    return;
  }
}

void keyPressed() {
if (key == ' ') {
    if (!flashlightOn && flashlightOnSound != null) {
      flashlightOnSound.rewind();
      flashlightOnSound.play();
    }
    flashlightOn = true;
  }
   if ((gameOver || gameWon) && key == 'r') {
    currentLevel = 1;        
    loadLevel(currentLevel); 
    restartGame();
  }
  if (key == 'w') player.jump();
  
}

void restartGame() {
  gameOver = false;
  gameWon = false;
  enemies.clear();
  bullets.clear();
  enemiesSpawned = 0;
  player = new Player();
}

void spawnEnemies() {
  if (currentLevel == 3) return;
  if (frameCount % 90 == 0 && enemiesSpawned < enemiesToSpawn) {
    float spawnX = 0;
    float spawnY = 0;
    int side = int(random(4));
    switch (side) {
      case 0: spawnX = 0; spawnY = random(height); break;
      case 1: spawnX = width; spawnY = random(height); break;
      case 2: spawnX = random(width); spawnY = 0; break;
      case 3: spawnX = random(width); spawnY = height; break;
    }
    enemies.add(new Enemy(spawnX, spawnY));
    enemiesSpawned++;
  }
}

void showGameOver() {
  fill(255, 0, 0);
  textSize(32);
  textAlign(CENTER);
  text("GAME OVER\nPress R to Restart", width / 2, height / 2);     // GAME OVER SCREEN
}

void showVictoryScreen() {
  background(0);
  textAlign(CENTER);
  textFont(titleFont);
  fill(255);
  text("YOU WIN!", width / 2, 60);     // WIN SCREEN

  if (trophyImage != null) {
    imageMode(CENTER);
    image(trophyImage, width / 2, height / 2 - 30);
  }

  textFont(bodyFont);
  text("Thanks for playing !", width / 2, height / 2 + 80);
}

void drawHealthBar() {
  float barWidth = 200;
  float barHeight = 20;
  float x = 20;
  float y = 20;

  float percent = player.health / 100.0;
  float currentWidth = barWidth * percent;

  fill(100);
  rect(x, y, barWidth, barHeight);

  fill(lerpColor(color(255, 0, 0), color(0, 255, 0), percent));
  rect(x, y, currentWidth, barHeight);

  noFill();
  stroke(255);
  rect(x, y, barWidth, barHeight);

  noStroke();
  fill(255);
  textSize(16);
  textAlign(LEFT);

  if (currentLevel == 3) {
    text("Final Level", x, y + 40);  // Only show "Final Level"
  } else {
    int remainingToSpawn = max(0, enemiesToSpawn - enemiesSpawned);
    text("Enemies On Screen: " + enemies.size(), x, y + 40);
    text("Remaining Enemies " + (enemies.size() + remainingToSpawn), x, y + 60);
  }
}

ArrayList<PVector> drawFlashlightCone() {
  ArrayList<PVector> conePoints = new ArrayList<PVector>();
  int segments = 80;
  float coneLength = 400;
  float coneAngle = radians(60);
  float centerX = player.x + 18;
  float centerY = player.y + 13;

  noStroke();
  for (int i = 0; i < segments; i++) {
    float angle1 = flashlightAngle + map(i, 0, segments, -coneAngle / 2, coneAngle / 2);
    float angle2 = flashlightAngle + map(i + 1, 0, segments, -coneAngle / 2, coneAngle / 2);

    float x1 = centerX + cos(angle1) * coneLength;
    float y1 = centerY + sin(angle1) * coneLength;
    float x2 = centerX + cos(angle2) * coneLength;
    float y2 = centerY + sin(angle2) * coneLength;

    fill(255, 255, 180, 80);
    beginShape();
    vertex(centerX, centerY);
    vertex(x1, y1);
    vertex(x2, y2);
    endShape(CLOSE);
  }

  for (int i = 0; i <= segments; i++) {
    float angle = flashlightAngle + map(i, 0, segments, -coneAngle / 2, coneAngle / 2);
    float x = centerX + cos(angle) * coneLength;
    float y = centerY + sin(angle) * coneLength;
    conePoints.add(new PVector(x, y));
  }

  return conePoints;
}

boolean isInFlashlightCone(Enemy e, ArrayList<PVector> conePoints) {
  if (conePoints.size() < 2) return false;
  PVector origin = new PVector(player.x, player.y);
  for (int i = 0; i < conePoints.size() - 1; i++) {
    PVector a = conePoints.get(i);
    PVector b = conePoints.get(i + 1);
    if (pointInTriangle(new PVector(e.x, e.y), origin, a, b)) return true;
  }
  return false;
}
boolean isInFlashlightCone(Boss b, ArrayList<PVector> conePoints) {
  if (conePoints.size() < 2) return false;
  PVector origin = new PVector(player.x, player.y);
  for (int i = 0; i < conePoints.size() - 1; i++) {
    PVector a = conePoints.get(i);
    PVector b2 = conePoints.get(i + 1);
    if (pointInTriangle(new PVector(b.x, b.y), origin, a, b2)) return true;
  }
  return false;
}

boolean pointInTriangle(PVector p, PVector a, PVector b, PVector c) {
  float area = 0.5 *(-b.y * c.x + a.y*(-b.x + c.x) + a.x*(b.y - c.y) + b.x*c.y);
  float s = 1/(2*area)*(a.y*c.x - a.x*c.y + (c.y - a.y)*p.x + (a.x - c.x)*p.y);
  float t = 1/(2*area)*(a.x*b.y - a.y*b.x + (a.y - b.y)*p.x + (b.x - a.x)*p.y);
  return s >= 0 && t >= 0 && (s + t) <= 1;
}
void drawStartScreen() {
  background(10);
  textFont(titleFont);
  fill(255);
  textAlign(CENTER);
  text(startText, width / 2, 60);

  imageMode(CENTER);
  image(characterImage, width / 2, 150);

  textFont(bodyFont);
  text("Use your flashlight to survive the undead.", width / 2, 240);
// Start Game Button
  rectMode(CENTER);
  fill(50, 150, 255);
  rect(width / 2, 290, 160, 40, 10);  // centerX, centerY
  fill(255);
  textAlign(CENTER, CENTER);
  text("START GAME", width / 2, 290);

// Description Button
fill(50, 150, 255);
rect(width / 2, 350, 160, 40, 10);  // centerX, centerY
fill(255);
text("DESCRIPTION", width / 2, 350);
}

void drawDescriptionScreen() {
  background(20);
  fill(255);
  textFont(titleFont);
  textAlign(CENTER);
  text("How to Play", width / 2, 50);

  textFont(bodyFont);
  textAlign(CENTER);
  text(descriptionText, width / 2, 190);


  rectMode(CENTER);
  fill(255);
  rect(width / 2, 360, 120, 35, 10);  // x=center, y=center
  
  fill(0); // Black text on white background for contrast
  textAlign(CENTER, CENTER);
  text("BACK", width / 2, 360);
}

void loadLevel(int level) {
  enemies.clear();
  bullets.clear();
  enemiesSpawned = 0;
  player = new Player();
  gameOver = false;
  gameWon = false;
  flashlightOn = false;
  levelWon = false;

  if (level == 1) {
    enemiesToSpawn = 10;
    bgImage = loadImage("dark.png");
    bgImage.resize(1000, 1000);
  } else if (level == 2) {
    enemiesToSpawn = 15;
    bgImage = loadImage("bg.png");
    bgImage.resize(800, 800);
  } else if (level == 3) {
    bossActive = true;
    bossHealth = 5;  // 👈 Reset health each time level 3 loads
    boss = new Boss(width - 80, height - 80);
    bgImage = loadImage("bg3.png");
    bgImage.resize(800, 800);
  }
}

void keyReleased() {
  if (key == ' ') {
    flashlightOn = false;
  }
}
