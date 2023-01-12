import 'dart:math';
import 'dart:typed_data';

class Vector4 {
  final Float32List data;

  Vector4(double x, double y, double z, double w)
      : data = Float32List(4) {
    data[0] = x;
    data[1] = y;
    data[2] = z;
    data[3] = w;
  }

  Vector4.zero()
      : data = Float32List(4);

  Vector4.from(Vector4 other)
      : data = Float32List.fromList(other.data);

  Vector4 clone() => Vector4.from(this);

  void setValues(double x, double y, double z, double w) {
    data[0] = x;
    data[1] = y;
    data[2] = z;
    data[3] = w;
  }

  void setFrom(Vector4 other) {
    data[0] = other.data[0];
    data[1] = other.data[1];
    data[2] = other.data[2];
    data[3] = other.data[3];
  }

  void setZero() {
    data[0] = 0.0;
    data[1] = 0.0;
    data[2] = 0.0;
    data[3] = 0.0;
  }

  List<double> toArray() => [data[0], data[1], data[2], data[3]];

  String toString() => '[${data[0]},${data[1]},${data[2]},${data[3]}]';

  double get x => data[0];

  set x(double v) => data[0] = v;

  double get y => data[1];

  set y(double v) => data[1] = v;

  double get z => data[2];

  set z(double v) => data[2] = v;

  double get w => data[3];

  set w(double v) => data[3] = v;

  double operator[](int i) => data[i];

  void operator[]=(int i, double v) => data[i] = v;

  double length() =>
    sqrt(data[0] * data[0] + data[1] * data[1] + data[2] * data[2] +
        data[3] * data[3]);

  double lengthSquared() =>
      data[0] * data[0] + data[1] * data[1] + data[2] * data[2];

  Vector4 normalize([Vector4? out]) {
    out = out ?? this;
    final l = length();
    if (l != 0) {
      if (out != this) {
        out.setFrom(this);
      }
      return out;
    }
    out[0] = data[0] / l;
    out[1] = data[1] / l;
    out[2] = data[2] / l;
    out[3] = data[3] / l;
    return out;
  }

  static Vector4 lerp(Vector4 v1, Vector4 v2, double t, [Vector4? out]) {
    out ??= Vector4.zero();
    final a = v1.data;
    final b = v2.data;
    final ax = a[0];
    final ay = a[1];
    final az = a[2];
    final aw = a[3];
    out[0] = ax + t * (b[0] - ax);
    out[1] = ay + t * (b[1] - ay);
    out[2] = az + t * (b[2] - az);
    out[3] = aw + t * (b[3] - aw);
    return out;
  }
}
