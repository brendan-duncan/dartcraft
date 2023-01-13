import 'dart:typed_data';

/// Psuedo Random Number Generator using the Xorshift128 algorithm
/// (https://en.wikipedia.org/wiki/Xorshift).
class Random {
  final data = Uint32List(6);

  Random([int? seed]) {
    this.seed = seed ?? DateTime.now().millisecondsSinceEpoch;
  }

  int get seed => data[0];

  set seed(int seed) {
    data[0] = seed;
    data[1] = data[0] * 1812433253 + 1;
    data[2] = data[1] * 1812433253 + 1;
    data[3] = data[2] * 1812433253 + 1;
  }

  /// Generates a random number between [0,0xffffffff]
  int randomUint32() {
    // Xorwow scrambling
    var t = data[3];
    final s = data[0];
    data[3] = data[2];
    data[2] = data[1];
    data[1] = s;
    t ^= t >> 2;
    t ^= t << 1;
    t ^= s ^ (s << 4);
    data[0] = t;
    data[4] += 362437;
    data[5] = (t + data[4])|0;
    return data[5];
  }

  /// Generates a random number between [0,1]
  double randomFloat() {
    final value = randomUint32();
    return (value & 0x007fffff) * (1.0 / 8388607.0);
  }

  /// Generates a random number between [0,1) with 53-bit resolution
  double randomDouble() {
    final a = randomUint32() >>> 5;
    final b = randomUint32() >>> 6;
    return (a * 67108864 + b) * (1.0 / 9007199254740992);
  }
}
