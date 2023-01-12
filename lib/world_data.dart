import 'package:dartcraft/voxel_data.dart';

import 'chunk_data.dart';

class WorldData {
  final String name;
  final int seed;
  final _chunks = <int, Map<int, ChunkData>>{};
  final _modifiedChunks = Set<ChunkData>();

  WorldData({this.name = 'world', this.seed = 12345 });

  Map<int, Map<int, ChunkData>> get chunks => _chunks;

  Set<ChunkData> get modifiedChunks => _modifiedChunks;

  void addToModifiedChunkList(ChunkData chunk) {
    if (!_modifiedChunks.contains(chunk)) {
      _modifiedChunks.add(chunk);
    }
  }

  ChunkData? getChunk(int x, int z) {
    final m = _chunks[z];
    if (m == null) {
      return null;
    }
    return m[x];
  }

  void setChunk(int x, int z, ChunkData chunk) {
    if (!_chunks.containsKey(z)) {
      _chunks[z] = {};
    }
    _chunks[z]![x] = chunk;
  }

  ChunkData? requestChunk(int x, int z, bool create) {
    var c = getChunk(x, z);
    if (c == null && create) {
      c = loadChunk(x, z);
    }
    return c;
  }

  ChunkData loadChunk(int x, int z) {
    var c = getChunk(x, z);
    if (c != null) {
      return c;
    }

    c = ChunkData(x, z);
    setChunk(x, z, c);
    c.populate();

    return c;
  }

  bool isVoxelInWorld(num x, num y, num z) =>
    y >= 0 && y < VoxelData.chunkHeight;

  void setVoxelId(num x, num y, num z, int value) {
    if (!isVoxelInWorld(x, y, z)) {
      return;
    }

    final cx = (x ~/ VoxelData.chunkWidth) * VoxelData.chunkWidth;
    final cz = (z ~/ VoxelData.chunkWidth) * VoxelData.chunkWidth;

    final chunk = requestChunk(cx, cz, true)!;

    chunk.modifyVoxel((x - cx).floor(), y.floor(), (z - cz).floor(), value);
  }

  int getVoxelId(num x, num y, num z) {
    if (!this.isVoxelInWorld(x, y, z)) {
      return 0;
    }

    final cx = (x ~/ VoxelData.chunkWidth) * VoxelData.chunkWidth;
    final cz = (z ~/ VoxelData.chunkWidth) * VoxelData.chunkWidth;

    final chunk = requestChunk(cx, cz, false);
    if (chunk == null) {
      return 0;
    }

    return chunk.getVoxelId((x - cx).floor(), y.floor(), (z - cz).floor());
  }

  num getVoxelLight(num x, num y, num z) {
    if (!isVoxelInWorld(x, y, z)) {
      return 0;
    }

    final cx = (x ~/ VoxelData.chunkWidth) * VoxelData.chunkWidth;
    final cz = (z ~/ VoxelData.chunkWidth) * VoxelData.chunkWidth;

    final chunk = requestChunk(cx, cz, false);
    if (chunk == null) {
      return 0;
    }

    return chunk.getVoxelLight((x - cx).floor(), y.floor(), (z - cz).floor());
  }
}
