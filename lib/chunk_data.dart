import 'dart:typed_data';

import 'block_type.dart';
import 'chunk.dart';
import 'globals.dart';
import 'lighting.dart';
import 'voxel_data.dart';

class ChunkData {
  int positionX;
  int positionY;
  Chunk? chunk;
  Uint8List voxelId;
  Uint8List voxelLight;

  ChunkData(this.positionX, this.positionY)
    : voxelId = Uint8List(VoxelData.chunkWidthHeightWidth)
    , voxelLight = Uint8List(VoxelData.chunkWidthHeightWidth) {
  }

  void populate() {
    const w = VoxelData.chunkWidth;
    const h = VoxelData.chunkHeight;
    for (var y = 0, vi = 0; y < h; ++y) {
      for (var z = 0; z < w; ++z) {
        for (var x = 0; x < w; ++x, ++vi) {
          final gx = x + positionX;
          final gy = y;
          final gz = z + positionY;

          voxelId[vi] = Globals.world!.calculateVoxel(gx, gy, gz);
          voxelLight[vi] = 0;
        }
      }
    }

    recalculateNaturalLight(this);
    Globals.world!.worldData.addToModifiedChunkList(this);
  }

  BlockType getVoxelProperties(int id) =>
    Globals.world!.blockTypes[id];

  int getVoxelIndex(int x, int y, int z) =>
    y * VoxelData.chunkWidthWidth + z * VoxelData.chunkWidth + x;

  int getVoxelId(int x, int y, int z) =>
    voxelId[y * VoxelData.chunkWidthWidth + z * VoxelData.chunkWidth + x];

  int setVoxelId(int x, int y, int z, int v) =>
    voxelId[y * VoxelData.chunkWidthWidth + z * VoxelData.chunkWidth + x] = v;

  int getVoxelLight(int x, int y, int z) =>
    voxelLight[y * VoxelData.chunkWidthWidth + z * VoxelData.chunkWidth + x];

  void setVoxelLight(int x, int y, int z, int v) =>
    voxelLight[y * VoxelData.chunkWidthWidth +
        z * VoxelData.chunkWidth + x] = v;

  void modifyVoxel(int x, int y, int z, int id) {
    final voxel = getVoxelId(x, y, z);
    if (voxel == id) {
      return;
    }

    final oldProperties = getVoxelProperties(voxel);
    final oldOpacity = oldProperties.opacity;

    setVoxelId(x, y, z, id);

    final newProperties = getVoxelProperties(id);

    // If the opacity values of the voxel have changed and the voxel above is
    // in direct sunlight (or is above the world), recast light from that voxel
    // downward.
    if (newProperties.opacity != oldOpacity &&
        (y == VoxelData.chunkHeight - 1 || getVoxelLight(x, y + 1, z) == 15)) {
      castNaturalLight(this, x, z, y + 1);
    }

    // Add this ChunkData to the modified chunks list.
    Globals.world!.worldData.addToModifiedChunkList(this);

    // If we have a chunk attached, add that for updating.
    if (chunk != null) {
      Globals.world!.addChunkToUpdate(chunk);
    }
  }

  bool isVoxelInChunk(int x, int y, int z) =>
      x >= 0 && x < VoxelData.chunkWidth &&
      y >= 0 && y < VoxelData.chunkHeight &&
      z >= 0 && z < VoxelData.chunkWidth;
}
