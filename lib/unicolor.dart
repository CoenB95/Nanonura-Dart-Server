class UniColors {
  static const UniColor black = UniColor(0xFF000000);
  static const UniColor blue = UniColor(0xFF0000FF);
  static const UniColor red = UniColor(0xFFF44336);
  static const UniColor white = UniColor(0xFFFFFFFF);
}

class UniColor {
  final int value;

  int get alpha => (value & 0xFF000000) >> 24;
  int get red   => (value & 0x00FF0000) >> 16;
  int get green => (value & 0x0000FF00) >> 8;
  int get blue  => (value & 0x000000FF) >> 0;

  const UniColor(int value) : value = 0xFFFFFFFF & value;

  const UniColor.fromARGB(int a, int r, int g, int b) :
        value = 0xFFFFFFFF &
        (((a & 0xff) << 24) |
         ((r & 0xff) << 16) |
         ((g & 0xff) <<  8) |
         ((b & 0xff) <<  0));

  static UniColor lerp(UniColor a, UniColor b, double progress) {
    return UniColor.fromARGB(
        (a.alpha + (b.alpha - a.alpha) * progress).toInt(),
        (a.red + (b.red - a.red) * progress).toInt(),
        (a.green + (b.green - a.green) * progress).toInt(),
        (a.blue + (b.blue - a.blue) * progress).toInt());
  }

  UniColor withAlpha(int value) => UniColor.fromARGB(value, red, green, blue);

  UniColor withRed(int value) => UniColor.fromARGB(alpha, value, green, blue);

  UniColor withGreen(int value) => UniColor.fromARGB(alpha, red, value, blue);

  UniColor withBlue(int value) => UniColor.fromARGB(alpha, red, green, value);

  UniColor operator +(other) {
    if (other is UniColor) {
      return UniColor.fromARGB(
          (this.alpha + other.alpha).clamp(0, 255),
          (this.red + other.red).clamp(0, 255),
          (this.green + other.green).clamp(0, 255),
          (this.blue + other.blue).clamp(0, 255));
    } else if (other is num) {
      return UniColor.fromARGB(
          (this.alpha + other).clamp(0, 255).toInt(),
          (this.red + other).clamp(0, 255).toInt(),
          (this.green + other).clamp(0, 255).toInt(),
          (this.blue + other).clamp(0, 255).toInt());
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
          (this.alpha - other).clamp(0, 255).toInt(),
          (this.red - other).clamp(0, 255).toInt(),
          (this.green - other).clamp(0, 255).toInt(),
          (this.blue - other).clamp(0, 255).toInt());
    }
    return null;
  }

  UniColor operator *(num other) {
    return UniColor.fromARGB(
        alpha,
        (this.red * other).clamp(0, 255).toInt(),
        (this.green * other).clamp(0, 255).toInt(),
        (this.blue * other).clamp(0, 255).toInt());
  }

  @override
  String toString() {
    return 'ARGB ($alpha, $red, $green, $blue)';
  }
}