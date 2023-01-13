import 'package:webgpu/webgpu.dart';

import 'chunk.dart';
import 'gpu/texture.dart';

class VoxelMaterial {
  GPUDevice device;
  late GPUSampler sampler;
  late Texture texture;
  late GPUBindGroupLayout bindGroupLayout;
  late GPUPipelineLayout pipelineLayout;
  late GPUShaderModule shaderModule;
  late GPURenderPipeline pipeline;
  late GPUBuffer viewUniformBuffer;
  int _chunkIndex = 0;
  final _modelBuffers = <GPUBuffer>[];
  final _bindGroups = <GPUBindGroup>[];

  VoxelMaterial(this.device) {
    sampler = device.createSampler(
      minFilter: GPUFilterMode.nearest, magFilter: GPUFilterMode.nearest,
        mipmapFilter: GPUFilterMode.linear);

    texture = Texture(device);

    bindGroupLayout = device.createBindGroupLayout(entries: [
        {
          // ViewUniforms
          'binding': 0,
          'visibility': GPUShaderStage.vertex,
          'buffer': { 'type': 'uniform' }
        },
        {
          // ModelUniforms
          'binding': 1,
          'visibility': GPUShaderStage.vertex,
          'buffer': { 'type': 'uniform' }
        },
        {
          // Sampler
          'binding': 2,
          'visibility': GPUShaderStage.fragment,
          'sampler': { 'type': 'filtering' }
        },
        {
          // Texture view
          'binding': 3,
          'visibility': GPUShaderStage.fragment,
          'texture': { 'sampleType': 'float' }
        }
      ]
    );

    pipelineLayout = device.createPipelineLayout([bindGroupLayout]);

    shaderModule = device.createShaderModule(code: shaderSource);

    pipeline = device.createRenderPipeline(descriptor: {
      'layout': pipelineLayout,
      'vertex': {
        'module': shaderModule,
        'entryPoint': 'vertexMain',
        'buffers': [
          {
            // Position
            'arrayStride': 3 * 4,
            'attributes': [
              {
                'shaderLocation': 0,
                'offset': 0,
                'format': 'float32x3'
              }
            ]
          },
          {
            // Normal
            'arrayStride': 3 * 4,
            'attributes': [
              {
                'shaderLocation': 1,
                'offset': 0,
                'format': 'float32x3'
              }
            ]
          },
          {
            // Color
            'arrayStride': 4 * 4,
            'attributes': [
              {
                'shaderLocation': 2,
                'offset': 0,
                'format':  'float32x4'
              }
            ]
          },
          {
            // UV
            'arrayStride': 2 * 4,
            'attributes': [
              {
                'shaderLocation': 3,
                'offset': 0,
                'format': 'float32x2'
              }
            ]
          }
        ]
      },
      'fragment': {
        'module': shaderModule,
        'entryPoint': 'fragmentMain',
        'targets': [ { 'format': 'bgra8unorm' } ]
      },
      'primitive': {
        'topology': 'triangle-list',
        'cullMode': 'none'
      },
      'depthStencil': {
        'depthWriteEnabled': true,
        'depthCompare': 'less',
        'format': 'depth24plus-stencil8'
      }
    });

    viewUniformBuffer = device.createBuffer(
      size: 4 * 16,
      usage: GPUBufferUsage.uniform | GPUBufferUsage.copyDst);

    _bindGroups.clear();
    _modelBuffers.clear();
  }

  Future<void> initialize() async {
    await texture.loadFile("resources/BlockAtlas.png");
  }

  void updateCamera(camera) {
    final modelViewProjection = camera.modelViewProjection;

    device.queue.writeBuffer(viewUniformBuffer, 0,
        modelViewProjection.data.buffer);
  }

  void startRender(passEncoder) {
    passEncoder.setPipeline(pipeline);
    _chunkIndex = 0;
  }

  void drawChunk(Chunk chunk, GPURenderPassEncoder passEncoder) {
    if (!texture.loaded) {
      return;
    }

    final chunkIndex = _chunkIndex;
    final modelBuffer = _getModelBuffer(chunkIndex);
    final bindGroup = _getBindGroup(chunkIndex);

    final mesh = chunk.mesh;
    final transform = chunk.worldTransform;

    device.queue.writeBuffer(modelBuffer, 0, transform.data.buffer);

    passEncoder.setBindGroup(0, bindGroup);
    passEncoder.setVertexBuffer(0, mesh!.buffers['points']!);
    passEncoder.setVertexBuffer(1, mesh.buffers['normals']!);
    passEncoder.setVertexBuffer(2, mesh.buffers['colors']!);
    passEncoder.setVertexBuffer(3, mesh.buffers['uvs']!);
    passEncoder.setIndexBuffer(mesh.buffers['triangles']!,
        GPUIndexFormat.uint16);
    passEncoder.drawIndexed(mesh.indexCount);

    _chunkIndex++;
  }

  GPUBuffer _getModelBuffer(index) {
    if (index < _modelBuffers.length) {
      return _modelBuffers[index];
    }

    final buffer = device.createBuffer(
      size: 4 * 16,
      usage: GPUBufferUsage.uniform | GPUBufferUsage.copyDst);
    _modelBuffers.add(buffer);

    return buffer;
  }

  GPUBindGroup _getBindGroup(index) {
    if (index < _bindGroups.length) {
      return _bindGroups[index];
    }

    final modelBuffer = _getModelBuffer(index);

    final bindGroup = device.createBindGroup(
      layout: pipeline.getBindGroupLayout(0),
      entries: [
        {
          'binding': 0,
          // TODO: buffer resource binding
          //'resource': { 'buffer': viewUniformBuffer }
          'resource': viewUniformBuffer
        },
        {
          'binding': 1,
          //'resource': {  'buffer': modelBuffer }
          'resource': modelBuffer
        },
        {
          'binding': 2,
          'resource': sampler
        },
        {
          'binding': 3,
          'resource': texture.createView()
        }
      ]
    );

    _bindGroups.add(bindGroup);

    return bindGroup;
  }
}

final shaderSource = '''
struct ViewUniforms {
  viewProjection: mat4x4<f32>
};

struct ModelUniforms {
  model: mat4x4<f32>
};

@binding(0) @group(0) var<uniform> viewUniforms: ViewUniforms;
@binding(1) @group(0) var<uniform> modelUniforms: ModelUniforms;

struct VertexInput {
  @location(0) a_position: vec3<f32>,
  @location(1) a_normal: vec3<f32>,
  @location(2) a_color: vec4<f32>,
  @location(3) a_uv: vec2<f32>
};

struct VertexOutput {
  @builtin(position) Position: vec4<f32>,
  @location(0) v_position: vec4<f32>,
  @location(1) v_normal: vec3<f32>,
  @location(2) v_color: vec4<f32>,
  @location(3) v_uv: vec2<f32>
};

@vertex
fn vertexMain(input: VertexInput) -> VertexOutput {
  var output: VertexOutput;
  output.Position = viewUniforms.viewProjection * modelUniforms.model *
      vec4<f32>(input.a_position, 1.0);
  output.v_position = output.Position;
  output.v_normal = input.a_normal;
  output.v_color = input.a_color;
  output.v_uv = input.a_uv;
  return output;
}

@binding(2) @group(0) var u_sampler: sampler;
@binding(3) @group(0) var u_texture: texture_2d<f32>;

@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4<f32> {
  let GlobalLightLevel: f32 = 0.8;
  let minGlobalLightLevel: f32 = 0.2;
  let maxGlobalLightLevel: f32 = 0.9;
  
  var shade: f32 = (maxGlobalLightLevel - minGlobalLightLevel) *
      GlobalLightLevel + minGlobalLightLevel;
  shade = shade * input.v_color.a;
  
  shade = clamp(shade, minGlobalLightLevel, maxGlobalLightLevel);
  
  var light: vec4<f32> = vec4<f32>(shade, shade, shade, 1.0);
  
  var outColor = textureSample(u_texture, u_sampler, input.v_uv) * light;
  
  return outColor;
}''';
