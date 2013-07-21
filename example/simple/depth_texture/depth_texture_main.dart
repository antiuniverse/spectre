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

library depth_texture_main;

import 'dart:async';
import 'dart:html';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:asset_pack/asset_pack.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:spectre/spectre_example_ui.dart';
import 'package:vector_math/vector_math.dart';

class DepthTextureExample extends Example {
  DepthTextureExample(CanvasElement element) : super('DepthTexture', element);

  Texture2D colorBuffer;
  Texture2D depthBuffer;
  RenderTarget renderTarget;
  OrbitCameraController cameraController;

  Future initialize() {
    return super.initialize().then((_) {
      if (!graphicsDevice.capabilities.hasDepthTextures) {
        throw new UnsupportedError('Computer does not support depth textures.');
      }
      // Create color buffer.
      colorBuffer = new Texture2D('colorBuffer', graphicsDevice);
      colorBuffer.uploadPixelArray(800, 600, null);
      // Create depth buffer.
      depthBuffer = new Texture2D('depthBuffer', graphicsDevice);
      depthBuffer.pixelFormat = PixelFormat.Depth;
      depthBuffer.pixelDataType = DataType.Uint32;
      depthBuffer.uploadPixelArray(800, 600, null);
      // Create render target.
      renderTarget = new RenderTarget('renderTarget', graphicsDevice);
      // Use color buffer.
      renderTarget.colorTarget = colorBuffer;
      // Use depth buffer.
      renderTarget.depthTarget = depthBuffer;
      // Verify that it's renderable.
      if (!renderTarget.isRenderable) {
        throw new UnsupportedError('Render target is not renderable: '
                                   '${renderTarget.statusCode}');
      }
      cameraController = new OrbitCameraController();
    });
  }

  Future load() {
    return super.load().then((_) {
    });
  }

  onUpdate() {
    Mouse mouse = gameLoop.mouse;
    if (mouse.isDown(Mouse.LEFT) || gameLoop.pointerLock.locked) {
      cameraController.accumDX = mouse.dx;
      cameraController.accumDY = mouse.dy;
    }

    cameraController.accumDZ = mouse.wheelDy;
    //cameraController.updateCamera(gameLoop.updateTimeStep, camera);
  }

  onRender() {
  }
}

main() {
  Example example = new DepthTextureExample(query('#backBuffer'));
  runExample(example);
}