import 'dart:typed_data';

import 'package:dartcraft/voxel_data.dart';

import 'chunk_data.dart';
import 'chunk_coord.dart';
import 'scene_object.dart';
import 'world.dart';
import 'gpu/mesh.dart';

class Chunk extends SceneObject {
  final ChunkCoord coord;
  final World world;
  int vertexIndex = 0;
  final vertices = <double>[];
  final triangles = <int>[];
  final transparentTriangles = <int>[];
  final uvs = <double>[];
  final normals = <double>[];
  final colors = <double>[];
  late final ChunkData chunkData;
  Mesh? mesh;

  Chunk(this.coord, this.world)
    : super('$coord', world) {

    final x = coord.x * VoxelData.chunkWidth;
    final z = coord.z * VoxelData.chunkWidth;
    setPosition(x, 0, z);

    chunkData = world.worldData.requestChunk(x, z, true)!;
    chunkData.chunk = this;

    world.addChunkToUpdate(this);
  }

  void updateChunk() {
    clearMeshData();

    for (var y = 0; y < VoxelData.chunkHeight; ++y) {
      for (var x = 0; x < VoxelData.chunkWidth; ++x) {
        for (var z = 0; z < VoxelData.chunkWidth; ++z) {
          final voxel = chunkData.getVoxelId(x, y, z);
          if (world.blockTypes[voxel].isSolid) {
            updateMeshData(x, y, z);
          }
        }
      }
    }

    world.chunksToDraw.add(this);
    mesh?.dirty = true;
  }

  void clearMeshData() {
    vertexIndex = 0;
    vertices.clear();
    triangles.clear();
    transparentTriangles.clear();
    uvs.clear();
    colors.clear();
    normals.clear();
  }

  editVoxel(num x, num y, num z, int newId) {
    final xCheck = x.floor() - position.x.floor();
    final yCheck = y.floor();
    final zCheck = z.floor() - position.z.floor();

    chunkData.modifyVoxel(xCheck, yCheck, zCheck, newId);

    updateSurroundingVoxels(xCheck, yCheck, zCheck);
  }

  void updateSurroundingVoxels(int x, int y, int z) {
    final pos = position;
    for (var p = 0; p < 6; ++p) {
      final cx = x + VoxelData.faceChecks[p][0];
      final cy = y + VoxelData.faceChecks[p][1];
      final cz = z + VoxelData.faceChecks[p][2];

      if (!chunkData.isVoxelInChunk(cx, cy, cz)) {
        world.addChunkToUpdate(
            world.getChunkFromPosition3(cx + pos.x,
              cy + pos.y, cz + pos.z), true);
      }
    }
  }

  int getVoxelIDFromGlobalPosition(num x, num y, num z) {
    final pos = position;
    final xCheck = x.floor() - pos.x.floor();
    final yCheck = y.floor() - pos.y.floor();
    final zCheck = z.floor() - pos.z.floor();
    return chunkData.getVoxelId(xCheck, yCheck, zCheck);
  }

  int getVoxelLightFromGlobalPosition(num x, num y, num z) {
    final pos = position;
    final xCheck = x.floor() - pos.x.floor();
    final yCheck = y.floor() - pos.y.floor();
    final zCheck = z.floor() - pos.z.floor();
    return chunkData.getVoxelLight(xCheck, yCheck, zCheck);
  }

  void updateMeshData(num x, num y, num z) {
    final xi = x.floor();
    final yi = y.floor();
    final zi = z.floor();

    final voxelID = chunkData.getVoxelId(xi, yi, zi);
    final properties = world.blockTypes[voxelID];

    final pos = position;
    final px = pos.x.floor();
    final py = pos.y.floor();
    final pz = pos.z.floor();

    final worldData = world.worldData;

    for (var p = 0; p < 6; ++p) {
      final nx = px + xi + VoxelData.faceChecks[p][0];
      final ny = py + yi + VoxelData.faceChecks[p][1];
      final nz = pz + zi + VoxelData.faceChecks[p][2];

      final neighborID = worldData.getVoxelId(nx, ny, nz);
      final neighborProperties = world.blockTypes[neighborID];

      //final neighbor = voxel.neighbors.get(p);
      final tri = VoxelData.voxelTris[p];

      if (world.blockTypes[neighborID].renderNeighborFaces) {
        vertices.addAll([
          x + VoxelData.voxelVerts[tri[0]][0],
          y + VoxelData.voxelVerts[tri[0]][1],
          z + VoxelData.voxelVerts[tri[0]][2],
          x + VoxelData.voxelVerts[tri[1]][0],
          y + VoxelData.voxelVerts[tri[1]][1],
          z + VoxelData.voxelVerts[tri[1]][2],
          x + VoxelData.voxelVerts[tri[2]][0],
          y + VoxelData.voxelVerts[tri[2]][1],
          z + VoxelData.voxelVerts[tri[2]][2],
          x + VoxelData.voxelVerts[tri[3]][0],
          y + VoxelData.voxelVerts[tri[3]][1],
          z + VoxelData.voxelVerts[tri[3]][2]
        ]);

        normals.addAll([
          VoxelData.voxelNormals[p][0],
          VoxelData.voxelNormals[p][1],
          VoxelData.voxelNormals[p][2],
          VoxelData.voxelNormals[p][0],
          VoxelData.voxelNormals[p][1],
          VoxelData.voxelNormals[p][2],
          VoxelData.voxelNormals[p][0],
          VoxelData.voxelNormals[p][1],
          VoxelData.voxelNormals[p][2],
          VoxelData.voxelNormals[p][0],
          VoxelData.voxelNormals[p][1],
          VoxelData.voxelNormals[p][2]
        ]);

        addTexture(properties.textures[p]);

        final lightLevel = worldData.getVoxelLight(nx, ny, nz) *
            VoxelData.unitOfLight;

        colors.addAll([
          0, 0, 0, lightLevel,
          0, 0, 0, lightLevel,
          0, 0, 0, lightLevel,
          0, 0, 0, lightLevel
        ]);

        if (!neighborProperties.renderNeighborFaces) {
          triangles.addAll([
            vertexIndex,
            vertexIndex + 1,
            vertexIndex + 2,
            vertexIndex + 2,
            vertexIndex + 1,
            vertexIndex + 3
          ]);
        } else {
          triangles.addAll([
            vertexIndex,
            vertexIndex + 1,
            vertexIndex + 2,
            vertexIndex + 2,
            vertexIndex + 1,
            vertexIndex + 3
          ]);
        }

        vertexIndex += 4;
      }
    }
  }

  void addTexture(int textureId) {
    var y = (textureId / VoxelData.textureAtlasSizeInBlocks).floorToDouble();
    var x = textureId - (y * VoxelData.textureAtlasSizeInBlocks);

    x *= VoxelData.normalizedBlockTextureSize;
    y *= VoxelData.normalizedBlockTextureSize;

    y = 1.0 - y - VoxelData.normalizedBlockTextureSize;

    final ps = VoxelData.normalizedTexturePixelSize * 2;

    x += ps;
    y += ps;
    final w = VoxelData.normalizedBlockTextureSize - (ps * 2);

    uvs.addAll([
      x,
      1.0 - y,
      x,
      1 - (y + w),
      x + w,
      1 - y,
      x + w,
      1 - (y + w)
    ]);
  }

  void createMesh(device) {
    if (mesh?.dirty == false) {
      return;
    }
    mesh?.destroy();

    final meshData = {
      'points': Float32List.fromList(vertices),
      'normals': Float32List.fromList(normals),
      'colors': Float32List.fromList(colors),
      'uvs': Float32List.fromList(uvs),
      'triangles': Uint16List.fromList(triangles)
    };

    mesh = Mesh(device, meshData);
  }
}
