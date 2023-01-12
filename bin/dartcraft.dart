import 'package:dartcraft/engine.dart';
import 'package:webgpu/webgpu.dart';

void main() async {
  await initializeWebGPU();
  final window = GPUWindow(width: 800, height: 600, title: 'DartCraft');
  final engine = Engine(window);

  await engine.initialize();

  while (!window.shouldQuit) {
    window.pollEvents();
    engine.update();
  }
}
