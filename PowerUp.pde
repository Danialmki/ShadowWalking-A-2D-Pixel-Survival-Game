class PowerUp extends Item {
  int duration = 300; // frames
  boolean active = false;

  PowerUp(float x, float y) {
    super(x, y, "image.png");
  }

  @Override
  void applyEffect(Player p) {
  }
}
