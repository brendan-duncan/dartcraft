import 'dart:math';
import 'dart:typed_data';

class Vector3 {
  final Float32List data;

  Vector3(double x, double y, double z)
      : data = Float32List(3) {
    data[0] = x;
    data[1] = y;
    data[2] = z;
  }

  Vector3.zero()
      : data = Float32List(3);

  Vector3.from(Vector3 other)
      : data = Float32List.fromList(other.data);

  Vector3 clone() => Vector3.from(this);

  void setValues(double x, double y, double z) {
    data[0] = x;
    data[1] = y;
    data[2] = z;
  }

  void setFrom(Vector3 other) {
    data[0] = other.data[0];
    data[1] = other.data[1];
    data[2] = other.data[2];
  }

  void setZero() {
    data[0] = 0.0;
    data[1] = 0.0;
    data[2] = 0.0;
  }

  List<double> toArray() => [data[0], data[1], data[2]];

  String toString() => '[${data[0]},${data[1]},${data[2]}]';

  double get x => data[0];

  set x(double v) => data[0] = v;

  double get y => data[1];

  set y(double v) => data[1] = v;

  double get z => data[2];

  set z(double v) => data[2] = v;

  double operator[](int i) => data[i];

  void operator[]=(int i, double v) => data[i] = v;

  double length() =>
      sqrt(data[0] * data[0] + data[1] * data[1] + data[2] * data[2]);

  double lengthSquared() =>
      data[0] * data[0] + data[1] * data[1] + data[2] * data[2];

  Vector3 normalize([Vector3? out]) {
    out ??= this;
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
    return out;
  }

  void add(Vector3 t) {
    data[0] += t.data[0];
    data[1] += t.data[1];
    data[2] += t.data[2];
  }
}
