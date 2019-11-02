import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

import 'package:Nanonura_Dart_Server/bulb.dart';
import 'package:Nanonura_Dart_Server/curve.dart';
import 'package:Nanonura_Dart_Server/effect.dart';
import 'package:Nanonura_Dart_Server/shows.dart';
import 'package:Nanonura_Dart_Server/unicolor.dart';

final int ledCount = 40;
Random random = Random();
List<Socket> displays = [];
List<Bulb> leds = [];
List<Show> programs = [];

Future main() async {
  for (int i = 0; i < ledCount; i++) {
    leds.add(Bulb(UniColors.black));
  }

  programs.addAll([
    EffectTestShow(ChaseEffect(bulbs: leds, durationSeconds: 10)),
    EffectTestShow(TwinkleEffect(bulbs: leds, durationSeconds: 10, gradient: Gradient.solid(UniColors.red))..rate = 5),
    SparkleTestShow()
  ]);

  var server = await ServerSocket.bind(
    InternetAddress.anyIPv4,
    10002,
  );
  print("Server's up: ${server.address}@${server.port}");

  double tock = 0;
  Timer.periodic(Duration(milliseconds: 10), (t) {
    loop(0.010);
    tock += 0.010;
    if (tock >= 1.0) {
      tock = 0;
      print('tick');
    }
  });

  server.listen((clientSocket) {
    print('Welcome new client!');
    displays.add(clientSocket);
    clientSocket.handleError((error) {
      print('error');
    }, test: (e) => true);
  });
}

int programTimer = 5000;

void loop(double elapsedSeconds) {
  if (programTimer <= 0) {
    Show show = programs[random.nextInt(programs.length)];
    show.active = !show.active;
    programTimer = random.nextInt(10000);
  }

  clearLeds();
  programs/*.where((s) => s.active)*/.forEach((s) => s.update(elapsedSeconds));
  programTimer -= 10;
  for (Socket client in displays) {
    pushLeds(client);
  }
}

void clearLeds() {
  for (int i = 0; i < ledCount; i++) {
    leds[i].color = UniColors.black;
  }
}

void pushLeds(Socket client) {
  List<int> buffer = [];
  buffer.addAll('abc'.codeUnits);
  for (Bulb led in leds) {
    buffer.add(led.color.red);
    buffer.add(led.color.green);
    buffer.add(led.color.blue);
  }
  buffer.addAll('def'.codeUnits);
  var bd = Uint8List.fromList(buffer);
  client.add(bd);
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