//import 'dart:math';

import 'biome_attributes.dart';
import 'block_type.dart';
import 'camera.dart';
import 'chunk.dart';
import 'chunk_coord.dart';
import 'globals.dart';
import 'math/noise.dart';
import 'math/random.dart';
import 'math/vector3.dart';
import 'math/vector4.dart';
import 'player.dart';
import 'settings.dart';
import 'transform.dart';
import 'world_data.dart';
import 'voxel_data.dart';

class World extends Transform {
  late List<BiomeAttributes> biomes;
  late WorldData worldData;
  late Random random;
  final spawnPosition = Vector3(0, 0, 0);
  late List<BlockType> blockTypes;
  final _chunks = <int, Map<int, Chunk>>{};
  final activeChunks = Set<ChunkCoord>();
  final chunksToDraw = <Chunk>[];
  final chunksToUpdate = <Chunk>[];
  final modifications = <List>[];
  var applyingModifications = false;
  final playerChunkCoord = ChunkCoord(0, 0);
  final playerLastChunkCoord = ChunkCoord(0, 0);
  final night = Vector4(0, 0, 77/255, 1);
  final day = Vector4(0, 1, 250/255, 1);
  final globalLightLevel = 1.0;
  final seed = 12345;
  final settings = Settings();
  
  World() {
    Globals.world = this;

    biomes = [
      BiomeAttributes(
        name: 'Grasslands',
        offset: 1234,
        scale: 0.042,
        terrainHeight: 22,
        terrainScale: 0.15,
        surfaceBlock: 3,
        subSurfaceBlock: 5,
        majorFloraIndex: 0,
        majorFloraZoneScale: 1.3,
        majorFloraZoneThreshold: 0.6,
        majorFloraPlacementScale: 15,
        majorFloraPlacementThreshold: 0.8,
        placeMajorFlora: true,
        maxHeight: 12,
        minHeight: 5,
        lodes: [
          Lode(
            name: 'Dirt',
            blockId: 5,
            minHeight: 1,
            maxHeight: 255,
            scale: 0.1,
            threshold: 0.5,
            noiseOffset: 0
          ),
          Lode(
            name: 'Sand',
            blockId: 4,
            minHeight: 30,
            maxHeight: 60,
            scale: 0.2,
            threshold: 0.6,
            noiseOffset: 500
          ),
          Lode(
            name: 'Caves',
            blockId: 0,
            minHeight: 5,
            maxHeight: 60,
            scale: 0.1,
            threshold: 0.55,
            noiseOffset: 43534
          )
        ]
      ),
      BiomeAttributes(
        name: 'Desert',
        offset: 6545,
        scale: 0.058,
        terrainHeight: 10,
        terrainScale: 0.05,
        surfaceBlock: 4,
        subSurfaceBlock: 4,
        majorFloraIndex: 1,
        majorFloraZoneScale: 1.06,
        majorFloraZoneThreshold: 0.75,
        majorFloraPlacementScale: 7.5,
        majorFloraPlacementThreshold: 0.8,
        placeMajorFlora: true,
        maxHeight: 12,
        minHeight: 5,
        lodes: [
          Lode(
            name: 'Dirt',
            blockId: 5,
            minHeight: 1,
            maxHeight: 255,
            scale: 0.1,
            threshold: 0.5,
            noiseOffset: 0
          ),
          Lode(
            name: 'Sand',
            blockId: 4,
            minHeight: 30,
            maxHeight: 60,
            scale: 0.2,
            threshold: 0.6,
            noiseOffset: 500
          ),
          Lode(
            name: 'Caves',
            blockId: 0,
            minHeight: 5,
            maxHeight: 60,
            scale: 0.1,
            threshold: 0.55,
            noiseOffset: 43534
          )
        ]
      ),
      BiomeAttributes(
        name: 'Forest',
        offset: 87544,
        scale: 0.17,
        terrainHeight: 80,
        terrainScale: 0.3,
        surfaceBlock: 5,
        subSurfaceBlock: 5,
        majorFloraIndex: 0,
        majorFloraZoneScale: 1.3,
        majorFloraZoneThreshold: 0.384,
        majorFloraPlacementScale: 5,
        majorFloraPlacementThreshold: 0.755,
        placeMajorFlora: true,
        maxHeight: 12,
        minHeight: 5,
        lodes: [
          Lode(
            name: 'Dirt',
            blockId: 5,
            minHeight: 1,
            maxHeight: 255,
            scale: 0.1,
            threshold: 0.5,
            noiseOffset: 0
          ),
          Lode(
            name: 'Sand',
            blockId: 4,
            minHeight: 30,
            maxHeight: 60,
            scale: 0.2,
            threshold: 0.6,
            noiseOffset: 500
          ),
          Lode(
            name: 'Caves',
            blockId: 0,
            minHeight: 5,
            maxHeight: 60,
            scale: 0.1,
            threshold: 0.55,
            noiseOffset: 43534
          )
        ]
      )
    ];

    worldData = WorldData(name: 'World', seed: 2147483647);

    random = Random(worldData.seed);

    blockTypes = [
      BlockType(name: 'Air', isSolid: false, textures: [0, 0, 0, 0, 0, 0], renderNeighborFaces: true, opacity: 0),
      BlockType(name: 'Bedrock', isSolid: true, textures: [9, 9, 9, 9, 9, 9], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Stone', isSolid: true, textures: [0, 0, 0, 0, 0, 0], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Grass', isSolid: true, textures: [2, 2, 7, 1, 2, 2], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Sand', isSolid: true, textures: [10, 10, 10, 10, 10, 10], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Dirt', isSolid: true, textures: [1, 1, 1, 1, 1, 1], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Wood', isSolid: true, textures: [5, 5, 6, 6, 5, 5], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Planks', isSolid: true, textures: [4, 4, 4, 4, 4, 4], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Bricks', isSolid: true, textures: [11, 11, 11, 11, 11, 11], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Cobblestone', isSolid: true, textures: [8, 8, 8, 8, 8, 8], renderNeighborFaces: false, opacity: 15),
      BlockType(name: 'Glass', isSolid: true, textures: [3, 3, 3, 3, 3, 3], renderNeighborFaces: true, opacity: 0),
      BlockType(name: 'Leaves', isSolid: true, textures: [16, 16, 16, 16, 16, 16], renderNeighborFaces: true, opacity: 5),
      BlockType(name: 'Cactus', isSolid: true, textures: [18, 18, 19, 19, 18, 18], renderNeighborFaces: true, opacity: 15),
      BlockType(name: 'Cactus Top', isSolid: true, textures: [18, 18, 17, 19, 18, 18], renderNeighborFaces: true, opacity: 15)
    ];
  }

  Camera get camera => Globals.camera!;

  Player get player => Globals.player!;

  void start() {
    random = Random(seed);

    loadWorld();
    setGlobalLightLevel();

    spawnPosition.setValues(VoxelData.worldCenter, VoxelData.chunkHeight - 75,
        VoxelData.worldCenter);

    player.position = spawnPosition;

    checkViewDistance();

    getChunkCoordFromPosition(player.position, playerLastChunkCoord);
  }

  update(device) {
    getChunkCoordFromPosition(player.position, playerChunkCoord);

    // Only update the chunks if the player has moved to a new chunk
    if (playerChunkCoord != playerLastChunkCoord) {
      checkViewDistance();
    }

    //while (chunksToDraw.length) {
    if (chunksToDraw.isNotEmpty) {
      chunksToDraw.removeLast().createMesh(device);
    }

    if (!applyingModifications) {
      applyModifications();
    }

    if (chunksToUpdate.isNotEmpty) {
      updateChunks();
    }
  }

  Chunk? getChunk(int x, int z) {
    final c = _chunks[x];
    if (c == null) {
      return null;
    }
    return c[z];
  }

  void setChunk(int x, int z, Chunk chunk) {
    var m = _chunks[x];
    if (m == null) {
      m = <int,Chunk>{};
      _chunks[x] = m;
    }
    m[z] = chunk;
  }

  ChunkCoord getChunkCoordFromPosition(Vector3 pos, ChunkCoord out) {
    out.x = pos.x ~/ VoxelData.chunkWidth;
    out.z = pos.z ~/ VoxelData.chunkWidth;
    return out;
  }

  Chunk? getChunkFromPosition(Vector3 pos) {
    final cx = pos.x ~/ VoxelData.chunkWidth;
    final cz = pos.z ~/ VoxelData.chunkWidth;
    return getChunk(cx, cz);
  }

  Chunk? getChunkFromPosition3(num x, num y, num z) {
    final cx = x ~/ VoxelData.chunkWidth;
    final cz = z ~/ VoxelData.chunkWidth;
    return getChunk(cx, cz);
  }

  void loadWorld() {
    //final hw = 10;
    final hw = VoxelData.worldSizeInChunks ~/ 2;
    final distance = settings.loadDistance;
    for (var x = hw - distance; x < hw + distance; ++x) {
      for (var z = hw - distance; z < hw + distance; ++z) {
        worldData.loadChunk(x, z);
      }
    }
  }

  void addChunkToUpdate(Chunk? chunk, [bool insert = false]) {
    if (chunk == null) {
      return;
    }
    if (!chunksToUpdate.contains(chunk)) {
      if (insert) {
        chunksToUpdate.insert(0, chunk);
      } else {
        chunksToUpdate.add(chunk);
      }
    }
  }

  void updateChunks() {
    if (chunksToUpdate.isEmpty) {
      return;
    }
    final chunk = chunksToUpdate.removeLast();
    chunk.updateChunk();
    if (!activeChunks.contains(chunk.coord)) {
      activeChunks.add(chunk.coord);
    }
  }

  void applyModifications() {
    applyingModifications = true;

    while (modifications.isNotEmpty) {
      final queue = modifications.removeLast();
      for (var i = queue.length - 1; i >= 0; --i) {
        final v = queue[i];
        final p = v.position;
        worldData.setVoxelId(p[0], p[1], p[2], v.id);
      }
    }

    applyingModifications = false;
  }

  void setGlobalLightLevel() {
    //material.setProperty('minGlobalLightLevel', VoxelData.minLightLevel);
    //material.setProperty('maxGlobalLightLevel', VoxelData.maxLightLevel);
    //material.setProperty('globalLightLevel', globalLightLevel);

    Vector4.lerp(night, day, globalLightLevel, camera.backgroundColor);
  }

  void checkViewDistance() {
    //clouds.updateClouds();

    playerLastChunkCoord.setFrom(playerChunkCoord);

    final playerPos = player.position;
    final chunkX = playerPos.x ~/ VoxelData.chunkWidth;
    final chunkZ = playerPos.z ~/ VoxelData.chunkWidth;

    // clone the activeChunks array
    var previouslyActiveChunks = Set<ChunkCoord>.from(activeChunks);

    activeChunks.clear();

    final viewDistance = settings.viewDistance;

    for (var x = chunkX - viewDistance; x <= chunkX + viewDistance; ++x) {
      for (var z = chunkZ - viewDistance; z <= chunkZ + viewDistance; ++z) {
        // If the chunk is within the world bounds and it has not been created.
        if (isChunkInWorld(x, z)) {
          var chunk = getChunk(x, z);
          if (chunk == null) {
            chunk = Chunk(ChunkCoord(x, z), this);
            setChunk(x, z, chunk);
          }

          chunk.active = true;
          activeChunks.add(chunk.coord);
        }

        // Check if this chunk was already in the active chunks list.
        final coord = ChunkCoord(x, z);
        previouslyActiveChunks.remove(coord);
      }
    }

    for (final coord in previouslyActiveChunks) {
      getChunk(coord.x, coord.z)!.active = false;
    }
  }

  bool isChunkInWorld(num x, num z) =>
    // An 'infinite' world.
    true;

  bool isVoxelInWorld(x, y, z) {
    // An 'infinite' world, at least in X and Z
    return y >= 0 && y < VoxelData.chunkHeight;
  }

  bool checkForVoxel(x, y, z) {
    final voxel = worldData.getVoxelId(x, y, z);
    return blockTypes[voxel].isSolid;
  }

  int getVoxelId(x, y, z) {
    return worldData.getVoxelId(x, y, z);
  }

  int calculateVoxel(x, y, z) {
    final yPos = y.floor();

    // If outside the world, return air
    if (!isVoxelInWorld(x, y, z)) {
      return 0;
    }

    // If bottom block of chunk, return bedrock.
    if (yPos == 0) {
      return 1;
    }

    var solidGroundHeight = 42;
    var sumOfHeights = 0.0;
    var count = 0;
    var strongestWeight = 0.0;
    var strongestBiomeIndex = 0;

    for (var i = 0, l = biomes.length; i < l; ++i) {
      final biome = biomes[i];
      final weight = World.get2DPerlin(x, z, biome.offset, biome.scale);

      // Keep track of which weight is strongest
      if (weight > strongestWeight) {
        strongestWeight = weight;
        strongestBiomeIndex = i;
      }

      final height = biome.terrainHeight *
          World.get2DPerlin(x, z, 0, biome.terrainScale) * weight;

      if (height > 0) {
        sumOfHeights += height;
        count++;
      }
    }

    // Set biome to the one with the strongest weight
    final biome = biomes[strongestBiomeIndex];

    // Get the average of the heights
    sumOfHeights /= count;

    final terrainHeight = (sumOfHeights + solidGroundHeight).floor();

    // Basic terrain pass
    var voxelValue = 0;

    if (yPos == terrainHeight) {
      voxelValue = biome.surfaceBlock;
    } else if (yPos < terrainHeight && yPos > terrainHeight - 4) {
      voxelValue = biome.subSurfaceBlock;
    } else if (yPos > terrainHeight) {
      return 0;
    } else {
      voxelValue = 2;
    }

    // Second pass
    if (voxelValue == 2) {
      for (var i = 0, l = biome.lodes.length; i < l; ++i) {
        final lode = biome.lodes[i];
        if (yPos > lode.minHeight && yPos < lode.maxHeight) {
          if (World.get3DPerlin(x, y, z, lode.noiseOffset, lode.scale, lode.threshold)) {
            voxelValue = lode.blockId;
          }
        }
      }
    }

    return voxelValue;
  }

  static get2DPerlin(x, y, offset, scale) {
    return Noise.perlinNoise2((x + 0.1) / VoxelData.chunkWidth * scale + offset,
        (y + 0.1) / VoxelData.chunkWidth * scale + offset);
  }

  static get3DPerlin(x, y, z, offset, scale, threshold) {
    x = (x + offset + 0.1) * scale;
    y = (y + offset + 0.1) * scale;
    z = (z + offset + 0.1) * scale;
    final AB = Noise.perlinNoise2(x, y);
    final BC = Noise.perlinNoise2(y, z);
    final AC = Noise.perlinNoise2(x, z);
    final BA = Noise.perlinNoise2(y, x);
    final CB = Noise.perlinNoise2(z, y);
    final CA = Noise.perlinNoise2(z, x);
    return ((AB + BC + AC + BA + CB + CA) / 6) > threshold;
  }
}
