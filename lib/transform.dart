import 'math/vector3.dart';
import 'math/matrix4.dart';

class Transform {
  Transform? parent;
  List<Transform> children = [];
  Vector3 _position = Vector3.zero();
  Vector3 _rotation = Vector3.zero();
  bool _localDirty = true;
  bool _worldDirty = true;
  Matrix4 _transform = Matrix4.identity();
  Matrix4 _worldTransform = Matrix4.identity();

  Transform([this.parent]) {
    parent?.children.add(this);
  }

  addChild(c) {
    children.add(c);
    c.parent = this;
    c.worldDirty = true;
  }

  Vector3 get position => _position;

  set position(Vector3 v) {
    _position.setFrom(v);
    localDirty = true;
  }

  void setPosition(double x, double y, double z) {
    _position.setValues(x, y, z);
    localDirty = true;
  }

  Vector3 get rotation => _rotation;

  set rotation(Vector3 v) {
    _rotation.setFrom(v);
    localDirty = true;
  }

  void setRotation(double x, double y, double z) {
    _rotation.setValues(x, y, z);
    localDirty = true;
  }

  bool get localDirty => _localDirty;

  set localDirty(bool v) {
    _localDirty = v;
    if (v) {
      worldDirty = true;
    }
  }

  bool get worldDirty => this._worldDirty;

  set worldDirty(bool v) {
    _worldDirty = v;
    if (v) {
      for (final c in children) {
        c.worldDirty = true;
      }
    }
  }

  Matrix4 get transform {
    if (this._localDirty) {
      _localDirty = false;
      _transform.setTranslate(position);
      _transform.rotateEuler(rotation);
    }
    return _transform;
  }

  Matrix4 get worldTransform {
    if (parent == null) {
      return this.transform;
    }

    if (_worldDirty) {
      final t = transform;
      final p = parent!.worldTransform;
      Matrix4.multiply(p, t, this._worldTransform);
      _worldDirty = false;
    }

    return _worldTransform;
  }

  Vector3 getWorldRight([Vector3? out]) {
    final t = worldTransform;
    return t.getColumn3(0, out);
  }

  Vector3 getWorldUp([Vector3? out]) {
    final t = worldTransform;
    return t.getColumn3(1, out);
  }

  Vector3 getWorldForward([Vector3? out]) {
    final t = worldTransform;
    return t.getColumn3(2, out);
  }

  Vector3 getWorldPosition([Vector3? out]) {
    final t = worldTransform;
    return t.getColumn3(3, out);
  }
}
