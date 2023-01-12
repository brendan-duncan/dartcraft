import 'math/vector3.dart';

class VoxelMod {
  final Vector3 position;
  final int id;

  VoxelMod({Vector3? position, int? id})
    : id = id ?? 0
    , position = position ?? Vector3.zero();
}
