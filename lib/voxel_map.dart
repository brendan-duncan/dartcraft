import 'dart:typed_data';

import 'voxel_data.dart';

class VoxelMap {
  Uint8List data;

  VoxelMap()
    : data = Uint8List(VoxelData.chunkWidth * VoxelData.chunkHeight * VoxelData.chunkWidth);

  int get(int x, int y, int z) =>
    data[z * VoxelData.chunkWidthHeight + y * VoxelData.chunkWidth + x];

  void set(int x, int y, int z, int v) =>
    data[z * VoxelData.chunkWidthHeight + y * VoxelData.chunkWidth + x] = v;
}
