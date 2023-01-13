import 'package:webgpu/webgpu.dart';

import 'camera.dart';
import 'engine.dart';
import 'input.dart';
import 'player.dart';
import 'world.dart';

class Globals {
  static double time = 0.0;
  static double deltaTime = 1.0 / 60.0;
  static double maxDeltaTime = 0.0;
  static double fixedDeltaTime = 1.0 / 60.0;
  static Camera? camera;
  static Engine? engine;
  static Player? player;
  static World? world;
  static GPUWindow? window;
  static Input? input;

  static int now() =>
    DateTime.now().millisecondsSinceEpoch;
}
