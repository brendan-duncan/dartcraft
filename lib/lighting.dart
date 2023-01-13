import 'chunk_data.dart';
import 'globals.dart';
import 'voxel_data.dart';

void recalculateNaturalLight(ChunkData chunkData) {
  for (var z = 0; z < VoxelData.chunkWidth; ++z) {
    for (var x = 0; x < VoxelData.chunkWidth; ++x) {
      castNaturalLight(chunkData, x, z, VoxelData.chunkHeight - 1);
    }
  }
}

void castNaturalLight(ChunkData chunkData, int x, int z, int startY) {
  // Little check to make sure we don't try and start from above the world.
  if (startY > VoxelData.chunkHeight - 1) {
    startY = VoxelData.chunkHeight - 1;
  }

  // Keep check of whether the light has hit a block with opacity
  var obstructed = false;

  for (var y = startY; y > -1; --y) {
    final index = chunkData.getVoxelIndex(x, y, z);
    final voxelId = chunkData.voxelId[index];
    final properties = Globals.world!.blockTypes[voxelId];

    if (obstructed) {
      chunkData.voxelLight[index] = 0;
    } else if (properties.opacity > 0) {
      chunkData.voxelLight[index] = 0;
      obstructed = true;
    } else {
      chunkData.voxelLight[index] = 15;
    }
  }
}
