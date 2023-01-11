import 'package:image/image.dart' as img;
import 'package:webgpu/webgpu.dart' as wgpu;
import 'texture_util.dart';

class Texture {
  wgpu.Device device;
  wgpu.Texture? gpu;
  int state;

  Texture(this.device)
    : state = 0 {
  }

  void destroy() {
    gpu?.destroy();
    gpu = null;
  }

  void create(int width, int height,
      {wgpu.TextureFormat format = wgpu.TextureFormat.rgba8unorm,
        wgpu.TextureUsage usage = wgpu.TextureUsage.textureBinding}) {
    gpu?.destroy();

    gpu = device.createTexture(width: width, height: height,
        format: format, usage: usage);

    state = 1;
  }

  Future<void> loadFile(String path) async {
    final image = await img.decodeImageFile(path);
    if (image == null) {
      return;
    }

    gpu = TextureUtil.get(device).generateMipmap(image);
    state = 1;
  }
}
