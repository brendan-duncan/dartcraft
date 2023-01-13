import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:webgpu/webgpu.dart';

class TextureUtil {
  static TextureUtil get(GPUDevice device) {
    var t = TextureUtil._devices[device];
    if (t != null) {
      return t;
    }
    t = TextureUtil(device);
    _devices[device] = t;
    return t;
  }

  GPUDevice device;
  late GPUSampler mipmapSampler;
  late GPURenderPipeline mipmapPipeline;

  TextureUtil(this.device) {
    mipmapSampler = device.createSampler(minFilter: 'linear');
    
    final shaderModule = device.createShaderModule(code: _mipmapShader);

    mipmapPipeline = device.createRenderPipeline(descriptor: {
      'vertex': {'module': shaderModule, 'entryPoint': 'vertexMain'},
      'fragment': {
          'module': shaderModule,
          'entryPoint': 'fragmentMain',
          'targets': [{'format': 'rgba8unorm'}]
      },
      'primitive': {
          'topology': 'triangle-strip',
          'stripIndexFormat': 'uint32'
      }
    });
  }

  static int getNumMipmapLevels(int w, int h) =>
    (log(max(w, h)) / log(2)).floor() + 1;

  GPUTexture generateMipmap(img.Image image) {
    var width = image.width;
    var height = image.height;

    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      image = image.convert(format: img.Format.uint8, numChannels: 4);
    }

    final mipLevelCount = getNumMipmapLevels(width, height);

    final texture = device.createTexture(width: width,
      height: height,
      format: 'rgba8unorm',
      usage: GPUTextureUsage.copyDst | GPUTextureUsage.textureBinding |
          GPUTextureUsage.renderAttachment,
      mipLevelCount: mipLevelCount);

    device.queue.writeTexture(
        destination: {'texture': texture},
        data: image.toUint8List(),
        dataLayout: {
          'bytesPerRow': image.rowStride,
          'rowsPerImage': image.height
        },
        width: image.width,
        height: image.height);

    final bindGroupLayout = mipmapPipeline.getBindGroupLayout(0);
    final commandEncoder = device.createCommandEncoder();

    for (var i = 1; i < mipLevelCount; ++i) {
      final bindGroup = device.createBindGroup(
        layout: bindGroupLayout,
        entries: [
          {'binding': 0, 'resource': mipmapSampler},
          {'binding': 1, 'resource': texture.createView(
            baseMipLevel: i - 1)}
        ]);

      final mipView = texture.createView(baseMipLevel: i);

      commandEncoder.beginRenderPass({
            'colorAttachments': [
              {
                'view': mipView,
                'loadOp': 'load',
                'storeOp': 'store'
              }
            ]
          })
      ..setPipeline(this.mipmapPipeline)
      ..setBindGroup(0, bindGroup)
      ..draw(3)
      ..end();

      width = (width / 2).ceil();
      height = (height / 2).ceil();
    }

    this.device.queue.submit([commandEncoder.finish()]);

    return texture;
  }

  static final Map<GPUDevice, TextureUtil> _devices = {};
}

const _mipmapShader = '''
var<private> posTex: array<vec4<f32>, 3> = array<vec4<f32>, 3>(
    vec4<f32>(-1.0, 1.0, 0.0, 0.0),
    vec4<f32>(3.0, 1.0, 2.0, 0.0),
    vec4<f32>(-1.0, -3.0, 0.0, 2.0));

struct VertexOutput {
    @builtin(position) v_position: vec4<f32>,
    @location(0) v_uv : vec2<f32>
};

@vertex
fn vertexMain(@builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
    var output: VertexOutput;

    output.v_uv = posTex[vertexIndex].zw;
    output.v_position = vec4<f32>(posTex[vertexIndex].xy, 0.0, 1.0);

    return output;
}

@binding(0) @group(0) var imgSampler: sampler;
@binding(1) @group(0) var img: texture_2d<f32>;

@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(img, imgSampler, input.v_uv);
}''';
