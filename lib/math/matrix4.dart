import 'dart:typed_data';

import 'math.dart';
import 'vector3.dart';
import 'vector4.dart';

class Matrix4 {
  final Float32List data;

  Matrix4.zero()
    : data = Float32List(16);

  Matrix4.identity()
    : data = Float32List(16) {
    data[0] = 1.0;
    data[5] = 1.0;
    data[10] = 1.0;
    data[15] = 1.0;
  }

  factory Matrix4(double arg0,
      double arg1,
      double arg2,
      double arg3,
      double arg4,
      double arg5,
      double arg6,
      double arg7,
      double arg8,
      double arg9,
      double arg10,
      double arg11,
      double arg12,
      double arg13,
      double arg14,
      double arg15) =>
      Matrix4.zero()
        ..setValues(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9,
            arg10, arg11, arg12, arg13, arg14, arg15);

  void setValues(double arg0,
      double arg1,
      double arg2,
      double arg3,
      double arg4,
      double arg5,
      double arg6,
      double arg7,
      double arg8,
      double arg9,
      double arg10,
      double arg11,
      double arg12,
      double arg13,
      double arg14,
      double arg15) {
    data[15] = arg15;
    data[14] = arg14;
    data[13] = arg13;
    data[12] = arg12;
    data[11] = arg11;
    data[10] = arg10;
    data[9] = arg9;
    data[8] = arg8;
    data[7] = arg7;
    data[6] = arg6;
    data[5] = arg5;
    data[4] = arg4;
    data[3] = arg3;
    data[2] = arg2;
    data[1] = arg1;
    data[0] = arg0;
  }

  void setFrom(Matrix4 other) {
    data.setAll(0, other.data);
  }

  Vector4 getColumn(int index, [Vector4? out]) {
    out ??= Vector4.zero();
    final i = index << 2;
    out[0] = data[i];
    out[1] = data[i + 1];
    out[2] = data[i + 2];
    out[3] = data[i + 3];
    return out;
  }

  Vector3 getColumn3(int index, [Vector3? out]) {
    out ??= Vector3.zero();
    final i = index << 2;
    out[0] = data[i];
    out[1] = data[i + 1];
    out[2] = data[i + 2];
    return out;
  }

  void setIdentity() {
    final m = data;
    m[0] = 1.0;
    m[1] = 0.0;
    m[2] = 0.0;
    m[3] = 0.0;
    m[4] = 0.0;
    m[5] = 1.0;
    m[6] = 0.0;
    m[7] = 0.0;
    m[8] = 0.0;
    m[9] = 0.0;
    m[10] = 1.0;
    m[11] = 0.0;
    m[12] = 0.0;
    m[13] = 0.0;
    m[14] = 0.0;
    m[15] = 1.0;
  }

  void setTranslate(Vector3 t) {
    final out = data;
    out[0] = 1;
    out[1] = 0;
    out[2] = 0;
    out[3] = 0;
    out[4] = 0;
    out[5] = 1;
    out[6] = 0;
    out[7] = 0;
    out[8] = 0;
    out[9] = 0;
    out[10] = 1;
    out[11] = 0;
    out[12] = t.x;
    out[13] = t.y;
    out[14] = t.z;
    out[15] = 1;
  }

  void setScale(Vector3 s) {
    final out = data;
    out[0] = s.x;
    out[1] = 0;
    out[2] = 0;
    out[3] = 0;
    out[4] = 0;
    out[5] = s.y;
    out[6] = 0;
    out[7] = 0;
    out[8] = 0;
    out[9] = 0;
    out[10] = s.z;
    out[11] = 0;
    out[12] = 0;
    out[13] = 0;
    out[14] = 0;
    out[15] = 1;
  }

  void setPerspective(double fovX, double aspect, double near, double far) {
    fovX *= degreesToRadians;
    final out = data;
    final f = 1.0 / tan(fovX / 2.0);
    out[0] = f / aspect;
    out[1] = 0;
    out[2] = 0;
    out[3] = 0;
    out[4] = 0;
    out[5] = f;
    out[6] = 0;
    out[7] = 0;
    out[8] = 0;
    out[9] = 0;
    out[11] = -1;
    out[12] = 0;
    out[13] = 0;
    out[15] = 0;
    final nearFar = 1.0 / (near - far);
    out[10] = (far + near) * nearFar;
    out[14] = (2.0 * far * near) * nearFar;
  }

  void scale(Vector3 v) {
    final x = v.x;
    final y = v.y;
    final z = v.z;
    final a = data;
    final out = data;
    out[0] = a[0] * x;
    out[1] = a[1] * x;
    out[2] = a[2] * x;
    out[3] = a[3] * x;
    out[4] = a[4] * y;
    out[5] = a[5] * y;
    out[6] = a[6] * y;
    out[7] = a[7] * y;
    out[8] = a[8] * z;
    out[9] = a[9] * z;
    out[10] = a[10] * z;
    out[11] = a[11] * z;
    out[12] = a[12];
    out[13] = a[13];
    out[14] = a[14];
    out[15] = a[15];
  }

  void rotateEuler(Vector3 angles) {
    rotateZ(angles.z);
    rotateY(angles.y);
    rotateX(angles.x);
  }

  void rotateX(double angle) {
    final rad = angle * degreesToRadians;
    final a = data;
    final out = data;

    final s = sin(rad);
    final c = cos(rad);
    final a10 = a[4];
    final a11 = a[5];
    final a12 = a[6];
    final a13 = a[7];
    final a20 = a[8];
    final a21 = a[9];
    final a22 = a[10];
    final a23 = a[11];

    // Perform axis-specific matrix multiplication
    out[4] = a10 * c + a20 * s;
    out[5] = a11 * c + a21 * s;
    out[6] = a12 * c + a22 * s;
    out[7] = a13 * c + a23 * s;
    out[8] = a20 * c - a10 * s;
    out[9] = a21 * c - a11 * s;
    out[10] = a22 * c - a12 * s;
    out[11] = a23 * c - a13 * s;
  }

  void rotateY(double angle) {
    final rad = angle * degreesToRadians;
    final a = data;
    final out = data;

    final s = sin(rad);
    final c = cos(rad);
    final a00 = a[0];
    final a01 = a[1];
    final a02 = a[2];
    final a03 = a[3];
    final a20 = a[8];
    final a21 = a[9];
    final a22 = a[10];
    final a23 = a[11];

    // Perform axis-specific matrix multiplication
    out[0] = a00 * c - a20 * s;
    out[1] = a01 * c - a21 * s;
    out[2] = a02 * c - a22 * s;
    out[3] = a03 * c - a23 * s;
    out[8] = a00 * s + a20 * c;
    out[9] = a01 * s + a21 * c;
    out[10] = a02 * s + a22 * c;
    out[11] = a03 * s + a23 * c;
  }

  void rotateZ(double angle) {
    final rad = angle * degreesToRadians;
    final a = data;
    final out = data;

    final s = sin(rad);
    final c = cos(rad);
    final a00 = a[0];
    final a01 = a[1];
    final a02 = a[2];
    final a03 = a[3];
    final a10 = a[4];
    final a11 = a[5];
    final a12 = a[6];
    final a13 = a[7];
    // Perform axis-specific matrix multiplication
    out[0] = a00 * c + a10 * s;
    out[1] = a01 * c + a11 * s;
    out[2] = a02 * c + a12 * s;
    out[3] = a03 * c + a13 * s;
    out[4] = a10 * c - a00 * s;
    out[5] = a11 * c - a01 * s;
    out[6] = a12 * c - a02 * s;
    out[7] = a13 * c - a03 * s;
  }

  Matrix4 invert([Matrix4? out]) {
    out ??= this;
    final a = data;
    final a00 = a[0];
    final a01 = a[1];
    final a02 = a[2];
    final a03 = a[3];
    final a10 = a[4];
    final a11 = a[5];
    final a12 = a[6];
    final a13 = a[7];
    final a20 = a[8];
    final a21 = a[9];
    final a22 = a[10];
    final a23 = a[11];
    final a30 = a[12];
    final a31 = a[13];
    final a32 = a[14];
    final a33 = a[15];

    final b00 = a00 * a11 - a01 * a10;
    final b01 = a00 * a12 - a02 * a10;
    final b02 = a00 * a13 - a03 * a10;
    final b03 = a01 * a12 - a02 * a11;
    final b04 = a01 * a13 - a03 * a11;
    final b05 = a02 * a13 - a03 * a12;
    final b06 = a20 * a31 - a21 * a30;
    final b07 = a20 * a32 - a22 * a30;
    final b08 = a20 * a33 - a23 * a30;
    final b09 = a21 * a32 - a22 * a31;
    final b10 = a21 * a33 - a23 * a31;
    final b11 = a22 * a33 - a23 * a32;

    // Calculate the determinant
    var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 +
        b05 * b06;
    if (det == 0.0) {
      return out;
    }
    det = 1.0 / det;

    final o = out.data;

    o[0] = (a11 * b11 - a12 * b10 + a13 * b09) * det;
    o[1] = (a02 * b10 - a01 * b11 - a03 * b09) * det;
    o[2] = (a31 * b05 - a32 * b04 + a33 * b03) * det;
    o[3] = (a22 * b04 - a21 * b05 - a23 * b03) * det;
    o[4] = (a12 * b08 - a10 * b11 - a13 * b07) * det;
    o[5] = (a00 * b11 - a02 * b08 + a03 * b07) * det;
    o[6] = (a32 * b02 - a30 * b05 - a33 * b01) * det;
    o[7] = (a20 * b05 - a22 * b02 + a23 * b01) * det;
    o[8] = (a10 * b10 - a11 * b08 + a13 * b06) * det;
    o[9] = (a01 * b08 - a00 * b10 - a03 * b06) * det;
    o[10] = (a30 * b04 - a31 * b02 + a33 * b00) * det;
    o[11] = (a21 * b02 - a20 * b04 - a23 * b00) * det;
    o[12] = (a11 * b07 - a10 * b09 - a12 * b06) * det;
    o[13] = (a00 * b09 - a01 * b07 + a02 * b06) * det;
    o[14] = (a31 * b01 - a30 * b03 - a32 * b00) * det;
    o[15] = (a20 * b03 - a21 * b01 + a22 * b00) * det;

    return out;
  }

  static Matrix4 multiply(Matrix4 m1, Matrix4 m2, Matrix4 out) {
    final a = m1.data;
    final b = m2.data;
    final o = out.data;

    final a00 = a[0];
    final a01 = a[1];
    final a02 = a[2];
    final a03 = a[3];
    final a10 = a[4];
    final a11 = a[5];
    final a12 = a[6];
    final a13 = a[7];
    final a20 = a[8];
    final a21 = a[9];
    final a22 = a[10];
    final a23 = a[11];
    final a30 = a[12];
    final a31 = a[13];
    final a32 = a[14];
    final a33 = a[15];

    var b0 = b[0];
    var b1 = b[1];
    var b2 = b[2];
    var b3 = b[3];
    o[0] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
    o[1] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
    o[2] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
    o[3] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

    b0 = b[4];
    b1 = b[5];
    b2 = b[6];
    b3 = b[7];
    o[4] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
    o[5] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
    o[6] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
    o[7] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

    b0 = b[8];
    b1 = b[9];
    b2 = b[10];
    b3 = b[11];
    o[8] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
    o[9] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
    o[10] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
    o[11] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

    b0 = b[12];
    b1 = b[13];
    b2 = b[14];
    b3 = b[15];
    o[12] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
    o[13] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
    o[14] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
    o[15] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

    return out;
  }
}
