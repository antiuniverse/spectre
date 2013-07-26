/*
  Copyright (C) 2013 John McCutchan

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commerci  al applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of spectre_example_ui;

abstract class Example {
  final String name;
  final CanvasElement element;
  GameLoopHtml gameLoop;
  AssetManager assetManager;
  GraphicsDevice graphicsDevice;
  GraphicsContext graphicsContext;
  DebugDrawManager debugDrawManager;
  Camera camera;
  Viewport viewport;
  SamplerState defaultSampler;
  SamplerState fullscreenSampler;
  SingleArrayMesh fullscreenMesh;
  DepthState fullscreenDepthState;

  Example(this.name, this.element) {
    graphicsDevice = new GraphicsDevice(element);
    graphicsContext = graphicsDevice.context;
    debugDrawManager = new DebugDrawManager(graphicsDevice);
    assetManager = new AssetManager();
    registerSpectreWithAssetManager(graphicsDevice, assetManager);
    gameLoop = new GameLoopHtml(element);
    gameLoop.onUpdate = _onUpdate;
    gameLoop.onRender = _onRender;
    gameLoop.onResize = _onResize;
    gameLoop.pointerLock.lockOnClick = false;
    camera = new Camera();
    camera.position = new Vector3(2.0, 2.0, 2.0);
    camera.focusPosition = new Vector3(1.0, 1.0, 1.0);
    element.width = element.clientWidth;
    element.height = element.clientHeight;
    viewport = new Viewport('element viewport', graphicsDevice);
    viewport.width = element.width;
    viewport.height = element.height;
    camera.aspectRatio = viewport.aspectRatio;
    defaultSampler = new SamplerState('defaultSampler', graphicsDevice);
    fullscreenSampler = new SamplerState.pointClamp('fullscreenSampler',
                                                    graphicsDevice);
    fullscreenDepthState = new DepthState('fullscreenDepthState',
                                          graphicsDevice);
    _fullscreenInit(graphicsDevice);
  }

  void _onRender(GameLoopHtml gl) {
    onRender();
  }

  void _onUpdate(GameLoopHtml gl) {
    debugDrawManager.update(gl.updateTimeStep);
    // Add three lines, one for each axis.
    debugDrawManager.addLine(new Vector3(0.0, 0.0, 0.0),
                             new Vector3(10.0, 0.0, 0.0),
                             new Vector4(1.0, 0.0, 0.0, 1.0));
    debugDrawManager.addLine(new Vector3(0.0, 0.0, 0.0),
                             new Vector3(0.0, 10.0, 0.0),
                             new Vector4(0.0, 1.0, 0.0, 1.0));
    debugDrawManager.addLine(new Vector3(0.0, 0.0, 0.0),
                             new Vector3(0.0, 0.0, 10.0),
                             new Vector4(0.0, 0.0, 1.0, 1.0));
    onUpdate();
  }

  void _onResize(GameLoopHtml gl) {
    element.width = gl.width;
    element.height = gl.height;
    viewport.width = gl.width;
    viewport.height = gl.height;

    if (camera != null) {
      // Change the aspect ratio of the camera
      camera.aspectRatio = viewport.aspectRatio;
    }
  }


  void _fullscreenInit(GraphicsDevice device) {
    fullscreenMesh = new SingleArrayMesh('FullscreenRenderable', device);
    Float32List vertexData = new Float32List(12);
    // Vertex 0
    vertexData[0] = -1.0;
    vertexData[1] = -1.0;
    vertexData[2] = 0.0;
    vertexData[3] = 0.0;
    // Vertex 1
    vertexData[4] = 3.0;
    vertexData[5] = -1.0;
    vertexData[6] = 2.0;
    vertexData[7] = 0.0;
    // Vertex 2
    vertexData[8] = -1.0;
    vertexData[9] = 3.0;
    vertexData[10] = 0.0;
    vertexData[11] = 2.0;
    fullscreenMesh.vertexArray.uploadData(vertexData, UsagePattern.StaticDraw);
    fullscreenMesh.attributes['vPosition'] =
        new SpectreMeshAttribute('vPosition',
            new VertexAttribute(0, 0, 0, 16, DataType.Float32, 2, false));
    fullscreenMesh.attributes['vTexCoord'] =
        new SpectreMeshAttribute('vTexCoord',
            new VertexAttribute(0, 0, 8, 16, DataType.Float32, 2, false));
    fullscreenMesh.count = 3;
  }

  void updateCameraConstants(Camera camera) {
    Matrix4 projectionMatrix = camera.projectionMatrix;
    Matrix4 viewMatrix = camera.viewMatrix;
    Matrix4 projectionViewMatrix = camera.projectionMatrix;
    projectionViewMatrix.multiply(viewMatrix);
    Matrix4 viewRotationMatrix = makeViewMatrix(new Vector3.zero(),
                                             camera.frontDirection,
                                             new Vector3(0.0, 1.0, 0.0));
    Matrix4 projectionViewRotationMatrix = camera.projectionMatrix;
    projectionViewRotationMatrix.multiply(viewRotationMatrix);
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['cameraView'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjection'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionView'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewMatrix.storage);
    }
    uniform = shader.uniforms['cameraViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewRotationMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewRotationMatrix.storage);
    }
  }

  void updateObjectTransformConstant(Matrix4 T) {
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['objectTransform'];
    if (uniform != null) {
      shader.updateUniform(uniform, T.storage);
    }
  }

  void updateCameraController(CameraController controller) {
    if (controller is FpsFlyCameraController) {
      controller.forward =
      gameLoop.keyboard.buttons[Keyboard.W].down;
      controller.backward =
      gameLoop.keyboard.buttons[Keyboard.S].down;
      controller.strafeLeft =
      gameLoop.keyboard.buttons[Keyboard.A].down;
      controller.strafeRight =
      gameLoop.keyboard.buttons[Keyboard.D].down;
      if (gameLoop.pointerLock.locked) {
        controller.accumDX = gameLoop.mouse.dx;
        controller.accumDY = gameLoop.mouse.dy;
      }
      controller.updateCamera(gameLoop.dt, camera);
    } else if (controller is OrbitCameraController) {
      Mouse mouse = gameLoop.mouse;
      if (mouse.isDown(Mouse.LEFT) || gameLoop.pointerLock.locked) {
        controller.accumDX = mouse.dx;
        controller.accumDY = mouse.dy;
      }
      controller.accumDZ = mouse.wheelDy;
      controller.updateCamera(gameLoop.updateTimeStep, camera);
    } else {
      throw new FallThroughError();
    }
  }

  Future initialize() {
    String assetUrl = 'packages/spectre/asset/base/_.pack';
    return assetManager.loadPack('base', assetUrl).then((_) {
      print('Base assets:');
      assetManager.root['base'].assets.forEach((k, v) {
        print('$k ${v.type} ${v.url}');
      });
      return this;
    });
  }

  Future shutdown() {
    return new Future.value(this);
  }

  Future load() {
    return new Future.value(this);
  }

  void start() {
    gameLoop.start();
  }

  void onUpdate();
  void onRender();
}
