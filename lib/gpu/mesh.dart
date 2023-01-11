import 'dart:typed_data';
import 'package:webgpu/webgpu.dart' as wgpu;

class Mesh {
  wgpu.Device device;
  Map<String, wgpu.Buffer> buffers;

  Mesh(this.device, Map<String, TypedData> attributes)
    : buffers = const {} {
    for (final a in attributes.keys) {
      final data = attributes[a]!;
      final buffer = device.createBuffer(size: data.lengthInBytes,
        usage: a == 'triangles' ? wgpu.BufferUsage.index :
          wgpu.BufferUsage.vertex,
        mappedAtCreation: true);

      if (data is Uint16List) {
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
