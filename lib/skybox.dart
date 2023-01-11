import 'gpu/cube_mesh.dart';
import 'gpu/texture.dart';

import 'package:webgpu/webgpu.dart' as wgpu;
import 'package:vector_math/vector_math.dart';

class Skybox {
  wgpu.Device device;
  late wgpu.Sampler sampler;
  late Texture texture;
  late Matrix4 transform;
  late Vector3 cameraPosition;
  late CubeMesh cube;
  late wgpu.BindGroupLayout bindGroupLayout;
  late wgpu.PipelineLayout pipelineLayout;
  late wgpu.ShaderModule shaderModule;
  late wgpu.RenderPipeline pipeline;

  Skybox(this.device) {
    sampler = wgpu.Sampler(device, minFilter: wgpu.FilterMode.linear,
      magFilter: wgpu.FilterMode.linear);
    texture = Texture(device);
    transform = Matrix4.zero();
    cameraPosition = Vector3.zero();
    cube = CubeMesh(device);
    
    bindGroupLayout = device.createBindGroupLayout(entries: [
      wgpu.BindGroupLayoutEntry(
          binding: 0,
          visibility: wgpu.ShaderStage.vertex,
          buffer: wgpu.BufferBindingLayout(
              type: wgpu.BufferBindingType.uniform)),
      wgpu.BindGroupLayoutEntry(
          binding: 1,
          visibility: wgpu.ShaderStage.fragment,
          sampler: wgpu.SamplerBindingLayout(
              type: wgpu.SamplerBindingType.filtering)),
      wgpu.BindGroupLayoutEntry(
          binding: 2,
          visibility: wgpu.ShaderStage.fragment,
          texture: wgpu.TextureBindingLayout(
              sampleType: wgpu.TextureSampleType.float))
    ]);
    
    pipelineLayout = device.createPipelineLayout([bindGroupLayout]);
    
    shaderModule = device.createShaderModule(code: _skyShader);

    /*pipeline = device.createRenderPipeline(wgpu.RenderPipelineDescriptor(
      layout: pipelineLayout,
      vertex: wgpu.VertexState(
        module: this.shaderModule,
        entryPoint: 'vertexMain',
        buffers: [
          wgpu.BufferState(
            arrayStride: CubeMesh.vertexSize,
            attributes: [
              {
                wgpu.Buffer
                // position
                shaderLocation: 0,
                offset: CubeMesh.positionOffset,
                format: 'float32x4'
              }
            ]
          )
        ]
      },
      fragment: {
        module: this.shaderModule,
        entryPoint: 'fragmentMain',
        targets: [
          {
            format: 'bgra8unorm'
          }
        ]
      },
      primitive: {
        topology: 'triangle-list',
        cullMode: 'none'
      },
      depthStencil: {
        depthWriteEnabled: false,
        depthCompare: 'less',
        format: 'depth24plus-stencil8'
      },
    ));*/
  }
  
  Future<void> initialize() async {
    await texture.loadFile('resources/sky2.jpg');
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
