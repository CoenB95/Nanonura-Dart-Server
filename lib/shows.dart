import 'package:Nanonura_Dart_Server/unicolor.dart';

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
}

class Gradient {
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
}