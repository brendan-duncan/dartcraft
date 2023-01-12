import 'package:dartcraft/math/vector4.dart';

import 'math/matrix4.dart';
import 'globals.dart';
import 'transform.dart';

class Camera extends Transform {
  double _aspect = 1.0;
  double _fov = 60.0;
  bool _projectionDirty = true;
  Matrix4 _projection = Matrix4.zero();
  bool _worldToViewDirty = true;
  bool _modelViewProjectionDirty = true;
  Matrix4 _worldToView = Matrix4.identity();
  Matrix4 _modelViewProjection = Matrix4.zero();
  Vector4 backgroundColor = Vector4.zero();

  Camera([Transform? parent])
    : super(parent) {
    Globals.camera = this;
    setPosition(0, 1.8, 0);
  }

  double get fov => _fov;

  set fov(double v) {
    if (_fov == v) {
      return;
    }
    _fov = v;
    projectionDirty = true;
  }

  double get aspect => _aspect;

  set aspect(double v) {
    if (_aspect == v) {
      return;
    }
    _aspect = v;
    projectionDirty = true;
  }

  bool get projectionDirty => _projectionDirty;

  set projectionDirty(bool v) {
    _projectionDirty = v;
    if (v) {
      _modelViewProjectionDirty = true;
    }
  }

  Matrix4 get projection {
    if (_projectionDirty) {
      _projection.setPerspective(fov, aspect, 0.3, 1000.0);
    }
    return _projection;
  }

  @override
  set localDirty(bool b) {
    super.localDirty = b;
    if (b) {
      _worldToViewDirty = true;
      _modelViewProjectionDirty = true;
      worldDirty = true;
    }
  }

  @override
  set worldDirty(bool b) {
    super.worldDirty = b;
    if (b) {
      _worldToViewDirty = true;
      _modelViewProjectionDirty = true;
    }
  }

  Matrix4 get worldToView {
    if (this._worldToViewDirty) {
      final t = worldTransform;
      _worldToView..setFrom(t)..invert();
      _worldToViewDirty = false;
    }
    return _worldToView;
  }

  Matrix4 get modelViewProjection {
    if (_modelViewProjectionDirty) {
      _modelViewProjectionDirty = false;
      Matrix4.multiply(projection, worldToView, this._modelViewProjection);
    }
    return _modelViewProjection;
  }
}
