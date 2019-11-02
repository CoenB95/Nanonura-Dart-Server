import 'package:Nanonura_Dart_Server/unicolor.dart';

class Bulb {
  UniColor color;

  Bulb(this.color);

  Bulb.off() : this(UniColors.black);
}