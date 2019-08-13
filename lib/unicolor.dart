class UniColors {
  static const UniColor black = UniColor(0xFF000000);
  static const UniColor red = UniColor(0xFFF44336);
  static const UniColor white = UniColor(0xFFFFFFFF);
}

class UniColor {
  final int value;

  int get alpha => value & 0xFF000000;
  int get red   => value & 0x00FF0000;
  int get green => value & 0x0000FF00;
  int get blue  => value & 0x000000FF;

  const UniColor(int value) : value = 0xFFFFFFFF & value;

  const UniColor.fromARGB(int a, int r, int g, int b) :
        value = 0xFFFFFFFF &
        (((a & 0xff) << 24) |
         ((r & 0xff) << 16) |
         ((g & 0xff) <<  8) |
         ((b & 0xff) <<  0));

  UniColor operator +(other) {
    if (other is UniColor) {
      return UniColor.fromARGB(
          (this.alpha + other.alpha).clamp(0, 255),
          (this.red + other.red).clamp(0, 255),
          (this.green + other.green).clamp(0, 255),
          (this.blue + other.blue).clamp(0, 255));
    } else if (other is num) {
      return UniColor.fromARGB(
          (this.alpha + other).clamp(0, 255),
          (this.red + other).clamp(0, 255),
          (this.green + other).clamp(0, 255),
          (this.blue + other).clamp(0, 255));
    }
    return null;
  }

  UniColor operator -(other) {
    if (other is UniColor) {
      return UniColor.fromARGB(
          (this.alpha - other.alpha).clamp(0, 255),
          (this.red - other.red).clamp(0, 255),
          (this.green - other.green).clamp(0, 255),
          (this.blue - other.blue).clamp(0, 255));
    } else if (other is num) {
      return UniColor.fromARGB(
          (this.alpha - other).clamp(0, 255),
          (this.red - other).clamp(0, 255),
          (this.green - other).clamp(0, 255),
          (this.blue - other).clamp(0, 255));
    }
    return null;
  }
}