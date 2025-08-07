void setupLevel2() {
  enemiesToSpawn = 7;
  enemies.clear();
  bullets.clear();
  enemiesSpawned = 0;
  player = new Player();
  gameOver = false;
  gameWon = false;
  flashlightOn = false;

  // Optional: change background or add new visuals
  bgImage = loadImage("bg_level2.png"); // You can replace this with a new image like "bg2.png"
  bgImage.resize(800, 800);
}
