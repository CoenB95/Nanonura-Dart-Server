import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

import 'package:Nanonura_Dart_Server/shows.dart';
import 'package:Nanonura_Dart_Server/unicolor.dart';

final int ledCount = 40;
Random random = Random();
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

  await for (Socket clientSocket in server) {
    print('Welcome new client!');
    loop(clientSocket);
  }
}

void loop(Socket clientSocket) async {
  int programTimer = 0;
  while (true) {
    if (programTimer <= 0) {
      Show show = programs[random.nextInt(programs.length)];
      show.active = !show.active;
      programTimer = random.nextInt(10000);
    }

    programs.where((s) => s.active).forEach((s) => s.update(0.010));
    programTimer -= 10;
    await pushLeds(clientSocket);
  }
}

class Led {
  UniColor color;

  Led(this.color);

  Led.off() : this(UniColors.black);
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
    buffer.add(led.color.red.toInt());
    buffer.add(led.color.green.toInt());
    buffer.add(led.color.blue.toInt());
  }
  buffer.addAll('def'.codeUnits);
  var bd = Uint8List.fromList(buffer);
  client.add(bd);
  await client.flush();
  await Future.delayed(Duration(milliseconds: 10));
}

class ChaseTestShow extends Show {
  double chaseProgress = 0;
  double timeout = 0;
  double durationSeconds = 2.5;
  Curve chase = Curve();

  ChaseTestShow() {
    chase.addMarker(0.0, 0.0);
  }

  void update(double elapsedSeconds) {
    if (timeout <= 0) {
      for (int i = 0; i < leds.length; i++) {
        double ledProgress = i.toDouble()/leds.length - chaseProgress;
      }
      leds[curLed] = Led(0, 0, 255);

      curLed++;
      timeout = 0.100;
      if (curLed >= ledCount) {
        curLed = 0;
      }
    }

    for (int i = 0; i < ledCount; i++) {
      leds[i] -= 1.0;
    }

    timeoutMillis -= elapsedSeconds;
  }
}

class TwinkleTestShow extends Show {
  double timeoutMillis = 0;

  void update(double elapsedSeconds) {
    if (timeoutMillis <= 0) {
      switch (random.nextInt(6)) {
        case 0:
          leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 255, 255, 0);
          break;
        case 1:
          leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 255, 0, 255);
          break;
        case 2:
          leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 0, 255, 255);
          break;
        case 3:
          leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 255, 0, 0);
          break;
        case 4:
          leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 0, 255, 0);
          break;
        case 5:
          leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 0, 0, 255);
          break;
      }
      timeoutMillis = 50;
    }

    timeoutMillis -= elapsedSeconds;
    for (int i = 0; i < ledCount; i++) {
      leds[i].color -= 2.5;
    }
  }
}

class SparkleTestShow extends Show {
  double timeoutMillis = 0;

  void update(double elapsedSeconds) {
    timeoutMillis -= elapsedSeconds;

    if (timeoutMillis <= 0) {
      for (int i = 0; i < random.nextInt(10); i++) {
        leds[random.nextInt(ledCount)].color = UniColor.fromARGB(255, 255, 255, 255);
      }
      timeoutMillis = 10;
    }
  }
}