import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

import 'package:Nanonura_Dart_Server/shows.dart';
import 'package:Nanonura_Dart_Server/unicolor.dart';

final int ledCount = 40;
Random random = Random();
List<Socket> displays = [];
List<Led> leds = [];
List<Show> programs = [
  ChaseTestShow(),
  TwinkleTestShow(),
  SparkleTestShow()
];

Future main() async {
  for (int i = 0; i < ledCount; i++) {
    leds.add(Led(UniColors.black));
  }

  var server = await ServerSocket.bind(
    InternetAddress.anyIPv4,
    10002,
  );
  print("Server's up: ${server.address}@${server.port}");

  Timer.periodic(Duration(milliseconds: 10), (t) async => await loop(0.010));

  server.listen((clientSocket) {
    print('Welcome new client!');
    displays.add(clientSocket);
  });
}

int programTimer = 0;

void loop(double elapsedSeconds) async {
  if (programTimer <= 0) {
    Show show = programs[random.nextInt(programs.length)];
    show.active = !show.active;
    programTimer = random.nextInt(10000);
  }

  programs/*.where((s) => s.active)*/.forEach((s) => s.update(0.010));
  programTimer -= 10;
  for (Socket client in displays) {
    await pushLeds(client);
  }
}

void clearLeds() {
  for (int i = 0; i < ledCount; i++) {
    leds[i] = Led.off();
  }
}

void pushLeds(Socket client) async {
  List<int> buffer = [];
  buffer.addAll('abc'.codeUnits);
  for (Led led in leds) {
    buffer.add(led.color.red);
    buffer.add(led.color.green);
    buffer.add(led.color.blue);
  }
  buffer.addAll('def'.codeUnits);
  var bd = Uint8List.fromList(buffer);
  client.add(bd);
  //await client.flush();
  //await Future.delayed(Duration(milliseconds: 10));
}

class ChaseTestShow extends Show {
  int childCount = ledCount;

  double get childDurationSeconds => chaseDurationSeconds / childCount;
  double childOverlap = 5;
  double chaseProgressSeconds = 0;
  double chaseDurationSeconds = 10;
  Curve curve = Curve.bulbPulse();

  void update(double elapsedSeconds) {
    if (chaseProgressSeconds > chaseDurationSeconds) {
      chaseProgressSeconds = 0;
    }

    for (int i = 0; i < leds.length; i++) {
      double chaseElapsed = (chaseDurationSeconds + childOverlap) / chaseDurationSeconds * chaseProgressSeconds - childOverlap / 2;
      double ledProgress = (chaseElapsed - i * childDurationSeconds + childOverlap / 2) / (childDurationSeconds + childOverlap);
      leds[i].color = UniColors.blue * curve.calculate(ledProgress);
    }

    chaseProgressSeconds += elapsedSeconds;
  }
}

class TwinkleTestShow extends Show {
  double timeoutMillis = 0;
  List<Lup> activeLeds = [];

  void update(double elapsedSeconds) {
    if (active && timeoutMillis <= 0) {
      Led led = leds[random.nextInt(ledCount)];
      double duration = 1.5;
      switch (random.nextInt(6)) {
        case 0:
          activeLeds.add(Lup(led, UniColor.fromARGB(255, 255, 255, 0), Curve.bulbPulse(), duration));
          break;
        case 1:
          activeLeds.add(Lup(led, UniColor.fromARGB(255, 255, 0, 255), Curve.bulbPulse(), duration));
          break;
        case 2:
          activeLeds.add(Lup(led, UniColor.fromARGB(255, 0, 255, 255), Curve.bulbPulse(), duration));
          break;
        case 3:
          activeLeds.add(Lup(led, UniColor.fromARGB(255, 255, 0, 0), Curve.bulbPulse(), duration));
          break;
        case 4:
          activeLeds.add(Lup(led, UniColor.fromARGB(255, 0, 255, 0), Curve.bulbPulse(), duration));
          break;
        case 5:
          activeLeds.add(Lup(led, UniColor.fromARGB(255, 0, 0, 255), Curve.bulbPulse(), duration));
          break;
      }
      timeoutMillis = 0.050;
    }

    timeoutMillis -= elapsedSeconds;

    activeLeds.removeWhere((l) => l.done);
    for (Lup lup in activeLeds) {
      lup.update(elapsedSeconds);
    }
  }
}

class SparkleTestShow extends Show {
  double timeoutMillis = 0;

  void update(double elapsedSeconds) {
    if (!active) {
      return;
    }

    timeoutMillis -= elapsedSeconds;

    if (timeoutMillis <= 0) {
      for (int i = 0; i < random.nextInt(10); i++) {
        leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 100, 100, 100);
      }
      timeoutMillis = 0.050;
    }
  }
}