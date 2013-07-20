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
  }

  void _onRender(GameLoopHtml gl) {
    graphicsContext.clearColorBuffer(0.97, 0.97, 0.97, 1.0);
    graphicsContext.clearDepthBuffer(1.0);
    graphicsContext.setViewport(viewport);
    onRender();
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
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

  Future initialize() {
    String assetUrl = 'packages/spectre/src/spectre_example_ui/assets/_.pack';
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
