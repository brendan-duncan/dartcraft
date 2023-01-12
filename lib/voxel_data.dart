class VoxelData {
  static const chunkWidth = 16;
  static const chunkHeight = 128;

  static const worldSizeInChunks = 40;

  // Lighting values
  static const minLightLevel = 0.1;
  static const maxLightLevel = 0.9;

  static const unitOfLight = 1 / 16;

  static const seed = 0;

  static const worldCenter = (worldSizeInChunks * chunkWidth) / 2;

  static const worldSizeInVoxels = worldSizeInChunks * chunkWidth;

  static const textureWidth = 256;
  static const normalizedTexturePixelSize = 1 / textureWidth;
  static const textureAtlasSizeInBlocks = 16;
  static const normalizedBlockTextureSize = 1 / textureAtlasSizeInBlocks;

  static const halfWorldSizeInChunks = worldSizeInChunks ~/ 2;
  static const viewDistanceInChunks = 10;
  static const halfViewDistanceInChunks = viewDistanceInChunks ~/ 2;
  static const worldSizeInBlocks = worldSizeInChunks * chunkWidth;
  static const chunkWidthHeight = chunkWidth * chunkHeight;
  static const chunkWidthWidth = chunkWidth * chunkWidth;
  static const chunkWidthHeightWidth = chunkWidthHeight * chunkWidth;

  static const voxelVerts = [
      [0.0, 0.0, 0.0],
      [1.0, 0.0, 0.0],
      [1.0, 1.0, 0.0],
      [0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0],
      [1.0, 0.0, 1.0],
      [1.0, 1.0, 1.0],
      [0.0, 1.0, 1.0],
  ];

  static const voxelNormals = [
      [0.0, 0.0, -1.0], // Back
      [0.0, 0.0, 1.0], // Front
      [0.0, 1.0, 0.0], // Top
      [0.0, -1.0, 0.0], // Bottom
      [-1.0, 0.0, 0.0], // Left
      [1.0, 0.0, 0.0] // Right
  ];

  static const voxelTris = [
      [0, 3, 1, 2], // Back Face
      [5, 6, 4, 7], // Front Face
      [3, 7, 2, 6], // Top Face
      [1, 5, 0, 4], // Bottom Face
      [4, 7, 0, 3], // Left Face
      [1, 2, 5, 6] // Right Face
  ];

  static const faceChecks = [
      [0, 0, -1],
      [0, 0, 1],
      [0, 1, 0],
      [0, -1, 0],
      [-1, 0, 0],
      [1, 0, 0]
  ];

  static const revFaceCheckIndex = [ 1, 0, 3, 2, 5, 4 ];
}
