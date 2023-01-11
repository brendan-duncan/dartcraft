import 'package:webgpu/webgpu.dart' as wgpu;

class Sampler {
  wgpu.Device device;
  late wgpu.Sampler gpu;
  Sampler(this.device) {
    gpu = device.createSampler();
  }
}
