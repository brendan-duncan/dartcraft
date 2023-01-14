import 'camera.dart';
import 'globals.dart';
import 'input.dart';
import 'math/vector3.dart';
import 'transform.dart';
import 'world.dart';

class Player extends Transform {
  Camera camera;
  bool isGrounded = false;
  bool isSprinting = false;
  double turnSpeed = 0.5;
  double walkSpeed = 5;
  double sprintSpeed = 10;
  double jumpForce = 5;
  double gravity = -9.8;

  double playerWidth = 0.15;
  double boundsTolerance = 0.1;

  double horizontal = 0;
  double vertical = 0;
  double mouseHorizontal = 0;
  double mouseVertical = 0;
  Vector3 velocity = Vector3.zero();
  double verticalMomentum = 0;
  bool jumpRequest = false;
  double checkIncrement = 0.1;
  double reach = 8;
  Vector3 _forward = Vector3.zero();
  //Vector3 _up = Vector3(0, 1, 0);
  Vector3 _right = Vector3.zero();
  Vector3 highlightPosition = Vector3.zero();
  Vector3 placePosition = Vector3.zero();
  double lastTime = 0;
  bool highlightActive = false;
  bool placeActive = false;
  
  Player(this.camera) {
    Globals.player = this;

    addChild(camera);

    lastTime = Globals.time;
  }

  World get world => Globals.world!;
  
  Input get input => Globals.input!;

  update() {
    calculateVelocity();
    if (jumpRequest) {
      jump();
    }

    camera.rotation[0] -= mouseVertical;
    rotation[1] -= mouseHorizontal;
    position.add(velocity);
    camera.localDirty = true;
    localDirty = true;

    mouseHorizontal = 0;
    mouseVertical = 0;

    placeCursorBlock();

    isSprinting = input.getKeyDown(KeyCode.leftShift);

    if (isGrounded && input.getKeyDown(KeyCode.space)) {
      jumpRequest = true;
    }

    if (input.getKeyDown(KeyCode.a)) {
      horizontal = -1;
    } else if (input.getKeyDown(KeyCode.d)) {
      horizontal = 1;
    } else {
      horizontal = 0;
    }

    if (input.getKeyDown(KeyCode.w)) {
      vertical = -1;
    } else if (input.getKeyDown(KeyCode.s)) {
      vertical = 1;
    } else {
      vertical = 0;
    }

    final editDelay = 2;

    /*if (input.getMouseButtonDown(0)) {
      final t = Globals.time;
      if ((t - lastTime) > editDelay) {
        if (placeActive) {
          final chunk = world.getChunkFromPosition(placePosition);
          if (chunk != null) {
            chunk.editVoxel(placePosition[0], placePosition[1],
                placePosition[2], 7);
            lastTime = t;
          }
        }
      }
    } else*/ if (input.getMouseButtonDown(0)) {
      final t = Globals.time;
      if ((t - lastTime) > editDelay) {
        if (highlightActive) {
          final chunk = world.getChunkFromPosition(highlightPosition);
          if (chunk != null) {
            chunk.editVoxel(highlightPosition[0], highlightPosition[1],
                highlightPosition[2], 0);
            lastTime = t;
          }
        }
      }
    }

    if (input.getMouseButtonDown(2)) {
      mouseHorizontal = input.deltaX * turnSpeed;
      mouseVertical = input.deltaY * turnSpeed;
    }
  }

  placeCursorBlock() {
    var step = checkIncrement;
    final pos = Vector3.zero();
    final lastPos = Vector3.zero();

    final camPos = camera.getWorldPosition();
    final camForward = camera.getWorldForward();

    while (step < reach) {
      pos.setValues(camPos[0] - (camForward[0] * step),
          camPos[1] - (camForward[1] * step),
          camPos[2] - (camForward[2] * step));

      if (world.checkForVoxel(pos[0], pos[1], pos[2])) {
        highlightActive = true;
        placeActive = true;
        highlightPosition.setValues(pos.x.floorToDouble(),
            pos.y.floorToDouble(), pos.z.floorToDouble());
        placePosition.setFrom(lastPos);
        return;
      }

      lastPos.setValues(pos.x.floorToDouble(), pos.y.floorToDouble(),
          pos.z.floorToDouble());

      step += checkIncrement;
    }

    highlightActive = false;
    placeActive = false;
  }

  void jump() {
    verticalMomentum = jumpForce;
    isGrounded = false;
    jumpRequest = false;
  }

  void calculateVelocity() {
    // Affect vertical momentum with gravity.
    if (verticalMomentum > gravity) {
      verticalMomentum += Globals.fixedDeltaTime * gravity;
    }

    getWorldForward(_forward);
    getWorldRight(_right);

    // if we're sprinting, use the sprint multiplier.
    final speed = isSprinting ? sprintSpeed : walkSpeed;

    final vx = (vertical * _forward.x + _right.x * horizontal) *
        Globals.fixedDeltaTime * speed;
    final vy = (vertical * _forward.y + _right.y * horizontal) *
        Globals.fixedDeltaTime * speed;
    final vz = (vertical * _forward.z + _right.z * horizontal) *
        Globals.fixedDeltaTime * speed;

    velocity.setValues(vx, vy, vz);

    // Apply vertical momentum (falling/jumping).
    velocity.y += verticalMomentum * Globals.fixedDeltaTime;

    if ((velocity.z > 0 && front) || (velocity.z < 0 && back)) {
      velocity.z = 0;
    }

    if ((velocity.x > 0 && right) || (velocity.x < 0 && left)) {
      velocity.x = 0;
    }

    if (velocity.y < 0) {
      velocity.y = checkDownSpeed(velocity.y);
    } else if (velocity.y > 0) {
      velocity.y = checkUpSpeed(velocity.y);
    }
  }

  /*onMouseMove(e) {
    if (document.pointerLockElement) {
      final turnSpeed = turnSpeed;
      mouseHorizontal = e.deltax * turnSpeed;
      mouseVertical = e.deltay * turnSpeed;
    }
  }

  onMouseDown() {
    input.lockMouse(true);
  }*/

  double checkDownSpeed(double downSpeed) {
    final pos = position;
    final width = playerWidth;
    final speed = downSpeed;

    if (world.checkForVoxel(pos.x - width, pos.y + speed, pos.z - width) ||
        world.checkForVoxel(pos.x + width, pos.y + speed, pos.z - width) ||
        world.checkForVoxel(pos.x + width, pos.y + speed, pos.z + width) ||
        world.checkForVoxel(pos.x - width, pos.y + speed, pos.z + width)) {
      isGrounded = true;
      return 0;
    }

    isGrounded = false;
    return downSpeed;
  }

  double checkUpSpeed(double upSpeed) {
    final pos = position;
    final width = playerWidth;
    final speed = 2 + upSpeed;

    if (world.checkForVoxel(pos.x - width, pos.y + speed, pos.z - width) ||
        world.checkForVoxel(pos.x + width, pos.y + speed, pos.z - width) ||
        world.checkForVoxel(pos.x + width, pos.y + speed, pos.z + width) ||
        world.checkForVoxel(pos.x - width, pos.y + speed, pos.z + width)) {
      return 0;
    }

    return upSpeed;
  }

  bool get front {
    final pos = position;
    if (world.checkForVoxel(pos.x, pos.y, pos.z + playerWidth) ||
        world.checkForVoxel(pos.x, pos.y + 1, pos.z + playerWidth)) {
      return true;
    }
    return false;
  }

  bool get back {
    final pos = position;
    if (world.checkForVoxel(pos.x, pos.y, pos.z - playerWidth) ||
        world.checkForVoxel(pos.x, pos.y + 1, pos.z - playerWidth)) {
      return true;
    }
    return false;
  }

  bool get left {
    final pos = position;
    if (world.checkForVoxel(pos.x - playerWidth, pos.y, pos.z) ||
        world.checkForVoxel(pos.x - playerWidth, pos.y + 1, pos.z)) {
      return true;
    }
    return false;
  }

  bool get right {
    final pos = position;
    if (world.checkForVoxel(pos.x + playerWidth, pos.y, pos.z) ||
        world.checkForVoxel(pos.x + playerWidth, pos.y + 1, pos.z)) {
      return true;
    }
    return false;
  }
}
