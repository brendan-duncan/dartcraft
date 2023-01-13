import 'package:webgpu/webgpu.dart';

class Input {
  static const leftButtonMask = 1;
  static const rightButtonMask = 2;
  static const middleButtonMask = 4;
  static const buttonMask = [leftButtonMask, middleButtonMask, rightButtonMask];

  GPUWindow window;

  Input(this.window);

  bool getKeyDown(int keyCode) =>
    window.isKeyPressed(keyCode);

  bool getKeyUp(int keyCode) => !getKeyDown(keyCode);

  bool getMouseButtonDown(int button) =>
    (window.mouseButton & buttonMask[button]) == buttonMask[button];

  int get deltaX => window.deltaX;

  int get deltaY => window.deltaY;
}

class KeyCode {
  static const space = 32 ;
  static const a = 65;
  static const d = 68;
  static const s = 83;
  static const w = 87;
  static const z = 90;
  static const rightShift = 16;
  static const leftShift = 16;
  static const rightControl = 17;
  static const leftControl = 17;
}
