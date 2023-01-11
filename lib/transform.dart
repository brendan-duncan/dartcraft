import 'package:vector_math/vector_math.dart';

class Transform {
  Transform? parent;
  List<Transform> children;
  late Vector3 _position;
  late Vector3 _rotation;
  bool _localDirty;
  bool _worldDirty;
  late Matrix4 _transform;
  late Matrix4 _worldTransform;

  Transform([this.parent])
    : children = const []
    , _localDirty = true
    , _worldDirty = true {
    this._position = new Vector3.zero();
    this._rotation = new Vector3.zero();
    this._transform = new Matrix4.identity();
    this._worldTransform = new Matrix4.identity();

    if (parent != null) {
      parent!.children.add(this);
    }
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

  void setPosition(num x, num y, num z) {
    _position..x = x.toDouble()
    ..y = y.toDouble()
    ..z = z.toDouble();
    localDirty = true;
  }

  Vector3 get rotation => _rotation;

  set rotation(Vector3 v) {
    _rotation.setFrom(v);
    localDirty = true;
  }

  void setRotation(num x, num y, num z) {
    _rotation..x = x.toDouble()
      ..y = y.toDouble()
      ..z = z.toDouble();
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
      _transform.setTranslation(position);
      _transform.rotate3(rotation);
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
      _worldTransform = p.multiplied(t);
      _worldDirty = false;
    }

    return _worldTransform;
  }

  Vector3 getWorldRight([Vector3? out]) {
    final t = worldTransform;
    final v4 = t.getColumn(0);
    out ??= Vector3.zero();
    out.setValues(v4.x, v4.y, v4.z);
    return out;
  }

  Vector3 getWorldUp([Vector3? out]) {
    final t = worldTransform;
    final v4 = t.getColumn(1);
    out ??= Vector3.zero();
    out.setValues(v4.x, v4.y, v4.z);
    return out;
  }

  Vector3 getWorldForward([Vector3? out]) {
    final t = worldTransform;
    final v4 = t.getColumn(2);
    out ??= Vector3.zero();
    out.setValues(v4.x, v4.y, v4.z);
    return out;
  }

  Vector3 getWorldPosition([Vector3? out]) {
    final t = worldTransform;
    final v4 = t.getColumn(3);
    out ??= Vector3.zero();
    out.setValues(v4.x, v4.y, v4.z);
    return out;
  }
}
