import 'package:Nanonura_Dart_Server/unicolor.dart';

class Led {
  UniColor color;

  Led(this.color);

  Led.off() : this(UniColors.black);
}

abstract class Show {
  bool active = false;

  void update(double elapsedSeconds);
}

class Marker<T> {
  final double elapsedSeconds;
  T object;

  Marker(this.elapsedSeconds, [this.object]);
}

class Curve {
  List<Marker<double>> _markers = [];

  Curve();

  Curve.off();

  Curve.on() {
    addMarker(0, 1.0);
  }

  Curve.bulbPulse() {
    addMarker(0.0, 0.0);
    addMarker(0.2, 1.0);
    addMarker(1.0, 0.0);
  }

  Curve.fadeOff() {
    addMarker(0.0, 1.0);
    addMarker(1.0, 0.0);
  }

  void addMarker(double progress, double value) {
    if (progress < 0 || progress > 1) {
      throw ArgumentError.value(
          progress, 'progress', 'Should be in the range [0-1]');
    }
    if (value < 0 || value > 1) {
      throw ArgumentError.value(
          value, 'value', 'Should be in the range [0-1]');
    }
    _markers.add(Marker(progress, value));
  }

  double calculate(double progress) {
    if (_markers.isEmpty) {
      return 0;
    }
    for (int i = 0; i < _markers.length; i++) {
      if (_markers[i].elapsedSeconds > progress) {
        if (i == 0) {
          //Before first marker.
          return 0;
        }

        //Between two markers.
        double innerProgress = (progress - _markers[i-1].elapsedSeconds) /
            (_markers[i].elapsedSeconds - _markers[i-1].elapsedSeconds);
        return _markers[i-1].object + (_markers[i].object - _markers[i-1].object) * innerProgress;
      }
    }

    //After last marker.
    return 0;
  }
}

class Lup {
  Led led;
  UniColor color;
  Curve curve;
  double progress = 0;
  double duration;
  bool get done => progress > duration;

  Lup(this.led, this.color, this.curve, this.duration);

  void update(double elapsedSeconds) {
    progress += elapsedSeconds;
    //led.color = UniColor.lerp(led.color, color * curve.calculate(progress / duration), progress/duration);
    led.color = UniColor.lerp(led.color, color, curve.calculate(progress / duration));
  }
}

/*class Gradient {
  List<Marker<UniColor>> _markers = [];

  Gradient();

  Curve.off();

  Curve.on() {
    addMarker(0, 1.0);
  }

  Curve.bulbPulse() {
    addMarker(0.0, 0.0);
    addMarker(0.2, 1.0);
    addMarker(1.0, 0.0);
  }

  void addMarker(double progress, double value) {
    if (progress < 0 || progress > 1) {
      throw ArgumentError.value(
          progress, 'progress', 'Should be in the range [0-1]');
    }
    if (value < 0 || value > 1) {
      throw ArgumentError.value(
          value, 'value', 'Should be in the range [0-1]');
    }
    _markers.add(Marker(progress, value));
  }

  double calculate(double progress) {
    if (_markers.isEmpty) {
      return 0;
    }
    for (int i = 0; i < _markers.length; i++) {
      if (_markers[i].object > progress) {
        if (i == 0) {
          //Before first marker.
          return _markers.first.object;
        }

        //Between two markers.
        (progress - _markers[i-1].object) / (_markers[i].object - _markers[i-1].object);
      }
    }

    //After last marker.
    return _markers.last.object;
  }
}*/
