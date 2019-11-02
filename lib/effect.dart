import 'dart:math';

import 'package:Nanonura_Dart_Server/bulb.dart';
import 'package:Nanonura_Dart_Server/curve.dart';
import 'package:Nanonura_Dart_Server/unicolor.dart';

abstract class Effect {
  List<Bulb> affectedBulbs = [];
  Curve curve = Curve.bulbPulse();
  Gradient gradient = Gradient.solid(UniColors.blue);
  double durationSeconds = 1.0;
  double progressSeconds = -1;

  bool get finished => progress >= 1.0 || progress < 0.0;
  double get progress => progressSeconds / durationSeconds;
  double get secondsLeft => durationSeconds - progressSeconds;

  Effect({Iterable<Bulb> bulbs, this.durationSeconds = 1.0, this.curve, this.gradient}) {
    if (bulbs != null) affectedBulbs.addAll(bulbs);
    if (curve == null) curve = Curve.bulbPulse();
    if (gradient == null) gradient = Gradient.solid(UniColors.blue);
  }

  void restart() {
    progressSeconds = 0;
  }

  void update(double elapsedSeconds) {
    if (progress < 0 || progress > 1) {
      return;
    }
    progressSeconds += elapsedSeconds;
  }
}

class ChaseEffect extends Effect {
  double get _childPercentage => 1.0 / affectedBulbs.length;
  double childOverlap = 0.50;

  ChaseEffect({Iterable<Bulb> bulbs, double durationSeconds = 1.0, Curve curve, Gradient gradient}) : super(
      bulbs: bulbs,
      durationSeconds: durationSeconds,
      curve: curve,
      gradient: gradient);

  @override
  void update(double elapsedSeconds) {
    super.update(elapsedSeconds);

    for (int i = 0; i < affectedBulbs.length; i++) {
      double chaseProgress = (1.0 + childOverlap) / 1.0 * progress - childOverlap / 2;
      double ledProgress = (chaseProgress - i * _childPercentage + childOverlap / 2) / (_childPercentage + childOverlap);
      affectedBulbs[i].color = UniColors.blue * curve.calculate(ledProgress, 0);
    }
  }
}

class PulseEffect extends Effect {
  PulseEffect({Iterable<Bulb> bulbs, double durationSeconds = 1.0, Gradient gradient, Curve curve}) : super(
      bulbs: bulbs,
      durationSeconds: durationSeconds,
      curve: curve,
      gradient: gradient);

  @override
  void update(double elapsedSeconds) {
    super.update(elapsedSeconds);

    for (int i = 0; i < affectedBulbs.length; i++) {
      affectedBulbs[i].color = gradient.calculate(progress, UniColors.black) * curve.calculate(progress, 0);
    }
  }
}

class TwinkleEffect extends Effect {
  List<PulseEffect> activeLeds = [];
  double rate = 20; //Hz

  double _timeoutSeconds = 0;
  Random _random = Random();

  TwinkleEffect({Iterable<Bulb> bulbs, double durationSeconds = 1.0, Curve curve, Gradient gradient}) : super(
      bulbs: bulbs,
      durationSeconds: durationSeconds,
      curve: curve,
      gradient: gradient);

  @override
  void update(double elapsedSeconds) {
    super.update(elapsedSeconds);

    if (_timeoutSeconds <= 0 && affectedBulbs.isNotEmpty && secondsLeft >= 1.5) {
      Bulb led;
      do {
        led = affectedBulbs[_random.nextInt(affectedBulbs.length)];
      } while (activeLeds.any((p) => p.affectedBulbs.contains(led)));
      UniColor color = UniColors.red;
      switch (_random.nextInt(6)) {
        case 0: color = UniColor.fromARGB(255, 255, 255, 0); break;
        case 1: color = UniColor.fromARGB(255, 255, 0, 255); break;
        case 2: color = UniColor.fromARGB(255, 0, 255, 255); break;
        case 3: color = UniColor.fromARGB(255, 255, 0, 0); break;
        case 4: color = UniColor.fromARGB(255, 0, 255, 0); break;
        case 5: color = UniColor.fromARGB(255, 0, 0, 255); break;
      }
      activeLeds.add(PulseEffect(
          bulbs: [led],
          durationSeconds: 1.5,
          gradient: Gradient.solid(color),
          curve: Curve.bulbPulse())..restart());
      _timeoutSeconds = 1.0 / rate;
    }

    _timeoutSeconds -= elapsedSeconds;

    activeLeds.removeWhere((l) => l.finished);
    for (Effect lup in activeLeds) {
      lup.update(elapsedSeconds);
    }
  }
}