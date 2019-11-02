import 'package:Nanonura_Dart_Server/effect.dart';

abstract class Show extends Effect {
  bool active = true;
}

class EffectTestShow extends Show {
  Effect effect;

  EffectTestShow(this.effect);

  @override
  void update(double elapsedSeconds) {
    if (active && effect.finished) {
      effect.restart();
    }

    effect.update(elapsedSeconds);
  }
}