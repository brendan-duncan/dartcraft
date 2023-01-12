import 'package:image/image.dart' as img;
import 'package:webgpu/webgpu.dart';
import 'texture_util.dart';

class Texture {
  GPUDevice device;
  GPUTexture? gpu;
  bool loaded;

  Texture(this.device)
    : loaded = false {
  }

  Texture.renderBuffer(this.device, int width, int height,
      GPUTextureFormat format)
    : loaded = false {
    create(width, height, format: format,
        usage: GPUTextureUsage.renderAttachment);
  }

  void destroy() {
    gpu?.destroy();
    gpu = null;
    loaded = false;
  }

  void create(int width, int height,
      {GPUTextureFormat format = GPUTextureFormat.rgba8unorm,
        GPUTextureUsage usage = GPUTextureUsage.textureBinding}) {
    gpu?.destroy();

    gpu = device.createTexture(width: width, height: height,
        format: format, usage: usage);

    loaded = true;
  }

  Future<void> loadFile(String path) async {
    final image = await img.decodeImageFile(path);
    if (image == null) {
      return;
    }

    gpu = TextureUtil.get(device).generateMipmap(image);
    loaded = true;
  }

  GPUTextureView createView() {
    return gpu!.createView();
  }
}
