import 'package:Nanonura_Dart_Server/unicolor.dart';

class Marker<T> {
  ///Position of this marker relative to its parent curve in 'progress'.
  final double startProgress;
  T value;

  Marker(this.startProgress, [this.value]);
}

abstract class MarkerSequence<T> {
  List<Marker<T>> _markers = [];

  void addMarker(double progress, T value) {
    if (progress < 0 || progress > 1) {
      throw ArgumentError.value(
          progress, 'progress', 'Should be in the range [0-1]');
    }

    _markers.add(Marker(progress, value));
  }

  T calculate(double progress, [T idleValue]) {
    if (_markers.isEmpty) {
      throw StateError("No markers in sequence");
    }
    for (int i = 0; i < _markers.length; i++) {
      if (_markers[i].startProgress > progress) {
        if (i == 0) {
          //Before first marker.
          if (idleValue != null) {
            return idleValue;
          } else {
            throw ArgumentError.value(
                progress, 'progress', 'Should be in the range [0-1]');
          }
        }

        //Between two markers.
        double innerProgress = (progress - _markers[i-1].startProgress) /
            (_markers[i].startProgress - _markers[i-1].startProgress);
        return _calculateLerp(_markers[i-1].value, _markers[i].value, innerProgress);
      }
    }

    //After last marker.
    //If there's only one marker, it's used for the whole timeline (0-1).
    if (_markers.length == 1 && progress <= 1.0) {
      return _markers[0].value;
    }

    //Otherwise we're past the timeline.
    if (idleValue != null) {
      return idleValue;
    } else {
      throw ArgumentError.value(
          progress, 'progress', 'Should be in the range [0-1]');
    }
  }

  T _calculateLerp(T a, T b, double progress);
}

class Curve extends MarkerSequence<double> {
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

  @override
  double _calculateLerp(double a, double b, double progress) {
    return a + (b - a) * progress;
  }
}

class Gradient extends MarkerSequence<UniColor> {
  Gradient();

  Gradient.solid(UniColor color) {
    addMarker(0.0, color);
  }

  @override
  UniColor _calculateLerp(UniColor a, UniColor b, double progress) {
    UniColor c = UniColor.lerp(a, b, progress);
    return c;
  }
}