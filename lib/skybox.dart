import 'package:webgpu/webgpu.dart';

import 'camera.dart';
import 'gpu/cube_mesh.dart';
import 'gpu/texture.dart';
import 'math/matrix4.dart';
import 'math/vector3.dart';


class Skybox {
  static final skyboxSize = Vector3(100.0, 100.0, 100.0);

  GPUDevice device;
  bool initialized = false;
  late GPUSampler sampler;
  late Texture texture;
  late Matrix4 transform;
  late Vector3 cameraPosition;
  late CubeMesh cube;
  late GPUBindGroupLayout bindGroupLayout;
  late GPUPipelineLayout pipelineLayout;
  late GPUShaderModule shaderModule;
  late GPURenderPipeline pipeline;
  late GPUBuffer uniformBuffer;
  late GPUBindGroup uniformBindGroup;

  Skybox(this.device);
  
  Future<void> initialize() async {
    texture = Texture(device);
    await texture.loadFile('resources/sky2.jpg');
    sampler = GPUSampler(device, minFilter: GPUFilterMode.linear,
        magFilter: GPUFilterMode.linear);
    transform = Matrix4.zero();
    cameraPosition = Vector3.zero();
    cube = CubeMesh(device);

    bindGroupLayout = device.createBindGroupLayout(entries: [
      {
        'binding': 0,
        'visibility': GPUShaderStage.vertex,
        'buffer': { 'type': 'uniform' }
      },
      {
        'binding': 1,
        'visibility': GPUShaderStage.fragment,
        'sampler': {'type': 'filtering'}
      },
      {
        'binding': 2,
        'visibility': GPUShaderStage.fragment,
        'texture': {'sampleType': 'float'}
      }
    ]);

    pipelineLayout = device.createPipelineLayout([bindGroupLayout]);

    shaderModule = device.createShaderModule(code: _skyShader);

    pipeline = device.createRenderPipeline(descriptor: {
      'layout': pipelineLayout,
      'vertex': {
        'module': shaderModule,
        'entryPoint': 'vertexMain',
        'buffers': [
          {
            'arrayStride': CubeMesh.vertexSize,
            'attributes': [
              {
                // position
                'shaderLocation': 0,
                'offset': CubeMesh.positionOffset,
                'format': 'float32x4'
              }
            ]
          }
        ]
      },
      'fragment': {
        'module': shaderModule,
        'entryPoint': 'fragmentMain',
        'targets': [{'format': 'bgra8unorm'}]
      },
      'primitive': {
        'topology': 'triangle-list',
        'cullMode': 'none'
      },
      'depthStencil': {
        'depthWriteEnabled': false,
        'depthCompare': 'less',
        'format': 'depth24plus-stencil8'
      },
    });

    const uniformBufferSize = 4 * 16; // 4x4 matrix
    uniformBuffer = device.createBuffer(size: uniformBufferSize,
        usage: GPUBufferUsage.uniform | GPUBufferUsage.copyDst);

    uniformBindGroup = device.createBindGroup(
        layout: pipeline.getBindGroupLayout(0),
        entries: [
          {'binding': 0, 'resource': this.uniformBuffer},
          {'binding': 1, 'resource': this.sampler},
          {'binding': 2, 'resource': texture.createView()}
        ]);
    initialized = true;
  }

  void draw(Camera camera, GPURenderPassEncoder encoder) {
    if (!this.initialized) {
      return;
    }

    final modelViewProjection = camera.modelViewProjection;
    transform.setIdentity();
    transform.setTranslate(camera.getWorldPosition(cameraPosition));
    transform.scale(skyboxSize);
    Matrix4.multiply(modelViewProjection, transform, transform);

    device.queue.writeBuffer(
        this.uniformBuffer,
        0,
        transform.data.buffer,
        transform.data.offsetInBytes,
        transform.data.lengthInBytes);

    encoder..setPipeline(pipeline)
    ..setBindGroup(0, uniformBindGroup)
    ..setVertexBuffer(0, cube.vertexBuffer)
    ..draw(36, 1, 0, 0);

    return;
  }
}

const _skyShader = '''
struct Uniforms {
u_modelViewProjection: mat4x4<f32>
};

@binding(0) @group(0) var<uniform> uniforms : Uniforms;

struct VertexInput {
@location(0) position: vec4<f32>
};

struct VertexOutput {
@builtin(position) Position: vec4<f32>,
@location(0) v_position: vec4<f32>
};

@vertex
fn vertexMain(input: VertexInput) -> VertexOutput {
var output: VertexOutput;
output.Position = uniforms.u_modelViewProjection * input.position;
output.v_position = input.position;
return output;
}

@binding(1) @group(0) var skySampler: sampler;
@binding(2) @group(0) var skyTexture: texture_2d<f32>;

fn polarToCartesian(V: vec3<f32>) -> vec2<f32> {
return vec2<f32>(0.5 - (atan2(V.z, V.x) / -6.28318531),
1.0 - (asin(V.y) / 1.57079633 * 0.5 + 0.5));
}

@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4<f32> {
var outColor = textureSample(skyTexture, skySampler, polarToCartesian(normalize(input.v_position.xyz)));
return outColor;
}''';
