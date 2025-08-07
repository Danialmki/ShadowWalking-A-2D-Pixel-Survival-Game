abstract class Item {
  PVector pos;
  PImage img;
  float size = 30;

  Item(float x, float y, String imageName) {
    pos = new PVector(x, y);
    img = loadImage(imageName);
    img.resize(int(size), int(size));
  }

  void display() {
    image(img, pos.x, pos.y);
  }

  abstract void applyEffect(Player p);
}
