import 'package:webgpu/webgpu.dart';

import 'globals.dart';
import 'gpu/texture.dart';
import 'camera.dart';
import 'chunk.dart';
import 'input.dart';
import 'player.dart';
import 'skybox.dart';
import 'world.dart';
import 'voxel_material.dart';

class Engine {
  bool initialized = false;
  GPUWindow window;
  late GPUAdapter adapter;
  late GPUDevice device;
  late GPUWindowContext context;
  late Texture depthTexture;
  late Skybox skybox;
  late Camera camera;
  late Player player;
  late World world;
  late VoxelMaterial voxelMaterial;
  late Map<String, Object> colorAttachment;
  late Map<String, Object> depthAttachment;
  late Map<String, Object> renderPassDescriptor;

  Engine(this.window);

  Future<void> initialize() async {
    Globals.engine = this;
    Globals.window = window;
    Globals.input = Input(window);

    adapter = await GPUAdapter.request();
    device = await adapter.requestDevice();

    context = window.createContext(adapter, device);
    context.configure();

    depthTexture = Texture.renderBuffer(device,
        window.width, window.height, GPUTextureFormat.depth24plus);

    colorAttachment = {
      'loadOp': GPULoadOp.clear,
      'clearValue': [0.1, 0.1, 0.1, 0.1],
      'storeOp': 'store'
    };

    depthAttachment = {
      'view': depthTexture.createView(),
      'depthLoadOp': 'clear',
      'depthClearValue': 1,
      'depthStoreOp': 'store'
    };

    renderPassDescriptor = {
      'colorAttachments': [colorAttachment],
      'depthStencilAttachment': depthAttachment
    };

    skybox = Skybox(device);
    await skybox.initialize();

    camera = Camera();

    player = Player(camera);
    world = World();

    voxelMaterial = VoxelMaterial(device);
    await voxelMaterial.initialize();

    world.start();

    initialized = true;

    Globals.time = Globals.now() * 0.1;
  }

  /*updateCanvasResolution() {
    final canvas = canvas;
    final rect = canvas.getBoundingClientRect();
    if (rect.width != canvas.width || rect.height != canvas.height) {
      canvas.width = rect.width;
      canvas.height = rect.height;
      _onCanvasResize();
    }
  }*/

  update() {
    final lastTime = Globals.time;
    Globals.time = Globals.now() * 0.01;
    Globals.deltaTime = Globals.time - lastTime;

    /*if (autoResizeCanvas) {
      updateCanvasResolution();
    }*/

    camera.aspect = window.width / window.height;

    world.update(device);
    player.update();

    voxelMaterial.updateCamera(camera);
  }

  render() {
    colorAttachment['view'] = context.getCurrentTextureView();

    final commandEncoder = device.createCommandEncoder();
    final passEncoder = commandEncoder.beginRenderPass(renderPassDescriptor);

    if (voxelMaterial.texture.loaded) {
      if (Globals.deltaTime > Globals.maxDeltaTime) {
        Globals.maxDeltaTime = Globals.deltaTime;
      }
    }

    final numObjects = world.children.length;
    var drawCount = 0;

    for (var i = 0; i < numObjects; ++i) {
      final chunk = world.children[i] as Chunk;
      if (!chunk.active) {
        continue;
      }

      if (chunk.mesh != null) {
        if (drawCount == 0) {
          voxelMaterial.startRender(passEncoder);
        }
        voxelMaterial.drawChunk(chunk, passEncoder);
        drawCount++;
      }
    }

    skybox.draw(camera, passEncoder);

    passEncoder.end();
    device.queue.submit([commandEncoder.finish()]);

    context.present();
  }

  /*void _onCanvasResize() {
    depthTexture.destroy();
    depthTexture = Texture.renderBuffer(device, window.width, window.height,
        GPUTextureFormat.depth24plusStencil8);

    depthAttachment.view = depthTexture.createView();
  }*/
}
