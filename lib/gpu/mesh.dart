import 'dart:typed_data';
import 'package:webgpu/webgpu.dart';

class Mesh {
  final GPUDevice device;
  final buffers = <String, GPUBuffer>{};
  bool dirty = false;
  int indexCount = 0;

  Mesh(this.device, Map<String, TypedData> attributes) {
    for (final a in attributes.keys) {
      final data = attributes[a]!;
      final buffer = device.createBuffer(size: data.lengthInBytes,
        usage: a == 'triangles' ? GPUBufferUsage.index : GPUBufferUsage.vertex,
        mappedAtCreation: true);

      if (data is Uint16List) {
        indexCount = data.length;
        buffer.getMappedRange().as<Uint16List>().setAll(0, data);
      } else if (data is Float32List) {
        buffer.getMappedRange().as<Float32List>().setAll(0, data);
      }

      buffer.unmap();

      buffers[a] = buffer;
    }
  }

  void destroy() {
    for (final b in buffers.values) {
      b.destroy();
    }
    buffers.clear();
  }
}
