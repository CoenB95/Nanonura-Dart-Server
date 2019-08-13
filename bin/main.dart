import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

final int ledCount = 40;

List<Led> leds = [];

Future main() async {
  for (int i = 0; i < ledCount; i++) {
    leds.add(Led(0, 0, 0));
  }

  var server = await ServerSocket.bind(
    InternetAddress.anyIPv4,
    10002,
  );
  print("Server's up: ${server.address}@${server.port}");

  await for (Socket clientSocket in server) {
    print('Welcome new client!');
    twinkleTest(clientSocket);
  }
}

class Led {
  final int r;
  final int g;
  final int b;

  Led(int r, int g, int b) :
        this.r = r < 0 ? 0 : r,
        this.g = g < 0 ? 0 : g,
        this.b = b < 0 ? 0 : b;

  Led.off() : this(0, 0, 0);

  Led operator -(int value) {
    return Led(r - value, g - value, b - value);
  }
}

void testShow(Socket client) async {
  int curLed = 0;
  int timeoutMillis = 0;

  while (true) {
    if (timeoutMillis <= 0) {
      leds[(curLed + 3) % ledCount] = Led(255, 0, 0);
      leds[(curLed + 2) % ledCount] = Led(0, 255, 0);
      leds[(curLed + 1) % ledCount] = Led(0, 0, 255);
      leds[curLed] = Led.off();

      curLed++;
      timeoutMillis = 500;
      if (curLed >= ledCount) {
        curLed = 0;
      }
    } else {
      leds[(curLed + 3) % ledCount] -= 10;
      leds[(curLed + 2) % ledCount] -= 10;
      leds[(curLed + 1) % ledCount] -= 10;
    }

    print('Testing led $curLed');
    List<int> buffer = [];
    buffer.addAll('abc'.codeUnits);
    for (Led led in leds) {
      buffer.add(led.r);
      buffer.add(led.g);
      buffer.add(led.b);
    }
    buffer.addAll('def'.codeUnits);
    var bd = Uint8List.fromList(buffer);
    client.add(bd);
    await client.flush();
    await Future.delayed(Duration(milliseconds: 10));
  }
}

void twinkleTest(Socket client) async {
  Random random = Random();
  int timeoutMillis = 0;

  while (true) {
    if (timeoutMillis <= 0) {
      leds[random.nextInt(ledCount)] = Led(255, 255, 255);
      timeoutMillis = random.nextInt(500);
    }

    timeoutMillis -= 10;
    for (int i = 0; i < ledCount; i++) {
      leds[i] -= 3;
    }

    List<int> buffer = [];
    buffer.addAll('abc'.codeUnits);
    for (Led led in leds) {
      buffer.add(led.r);
      buffer.add(led.g);
      buffer.add(led.b);
    }
    buffer.addAll('def'.codeUnits);
    var bd = Uint8List.fromList(buffer);
    client.add(bd);
    await client.flush();
    await Future.delayed(Duration(milliseconds: 10));
  }
}