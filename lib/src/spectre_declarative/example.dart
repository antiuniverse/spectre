/*
  Copyright (C) 2013 John McCutchan

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of spectre_declarative;

class DeclarativeExample extends Example {
  DeclarativeExample(CanvasElement element)
      : super('DeclarativeExample', element);

  String sceneId = '#scene';
  CameraController cameraController;

  Future initialize() {
    return super.initialize().then((_) {
      cameraController = new FpsFlyCameraController();
      SpectreElement.debugDrawManager = debugDrawManager;
      SpectreElement.graphicsContext = graphicsContext;
      SpectreElement.graphicsDevice = graphicsDevice;
      SpectreElement.assetManager = assetManager;
    });
  }

  Future load() {
    return super.load().then((_) {
    });
  }

  onUpdate() {
    updateCameraController(cameraController);
  }

  onRender() {
    // Set the viewport (2D area of render target to render on to).
    graphicsContext.setViewport(viewport);
    // Clear it.
    graphicsContext.clearColorBuffer(0.97, 0.97, 0.97, 1.0);
    graphicsContext.clearDepthBuffer(1.0);


    SpectreSceneElement scene = query(sceneId).xtag;
    if (scene == null) {
      return;
    }

    SpectreElement.scene = scene;
    scene.pushCamera(camera);

    scene.apply();
    scene.render();
    scene.unapply();

    scene.popCamera();

    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
  }
}
