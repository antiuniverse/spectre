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

library declarative_main;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:math' as Math;
import 'dart:async';
import 'dart:typed_data';

import 'package:asset_pack/asset_pack.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:mdv/mdv.dart' as mdv;
import 'package:observe/observe.dart';
import 'package:polymer/polymer.dart' as polymer;
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:spectre/spectre_example_ui.dart';
import 'package:spectre/spectre_declarative.dart';

class DeclarativeState {
  static AssetManager assetManager;
  static GraphicsDevice graphicsDevice;
  static GraphicsContext graphicsContext;
  static DebugDrawManager debugDrawManager;
  static SpectreSceneElement scene;
  static bool _inited = false;
  static bool get inited => _inited;

  static void _initElement(SpectreElement element) {
    element.init();
    element.children.forEach((e) {
      if (e.xtag is SpectreElement) {
        e = e.xtag;
        _initElement(e);
      }
    });
  }

  static void _init() {
    if (_inited) {
      return;
    }
    _inited = true;
    _initElement(scene);
  }

  static bool _isAssetPackUrl(String url) {
    return url.startsWith('assetpack://');
  }

  static String _getAssetPackPath(String url) {
    return url.substring('assetpack://'.length);
  }

  static dynamic getAsset(String url) {
    assert(_inited == true);
    assert(_isAssetPackUrl(url));
    var p = _getAssetPackPath(url);
    var a = assetManager[p];
    return a;
  }
}

class DeclarativeExample extends Example {
  String sceneId;
  DeclarativeExample(CanvasElement element, this.sceneId)
      : super('DeclarativeExample', element);

  CameraController cameraController;

  Future initialize() {
    return super.initialize().then((_) {
      cameraController = new FpsFlyCameraController();
      DeclarativeState.debugDrawManager = debugDrawManager;
      DeclarativeState.graphicsContext = graphicsContext;
      DeclarativeState.graphicsDevice = graphicsDevice;
      DeclarativeState.assetManager = assetManager;
      var ele = query(sceneId);
      if (ele == null) {
        throw new ArgumentError('Could not find $sceneId in dom.');
      }
      var scene = ele.xtag;
      if (scene is! SpectreSceneElement) {
        throw new ArgumentError('$sceneId is not a <s-scene>');
      }
      DeclarativeState.scene = scene;
      DeclarativeState._init();
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

    var scene = DeclarativeState.scene;

    scene.pushCamera(camera);
    scene.render();
    scene.popCamera();

    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
  }
}

Future main(String backBufferId, String sceneId) {
  mdv.initialize();

  polymer.setScopedCss('s-camera', {"s-camera":"[is=\"s-camera\"]"});
  polymer.registerPolymerElement('s-camera', () => new SpectreCameraElement());

  polymer.setScopedCss('s-fragment-shader', {"s-fragment-shader":"[is=\"s-fragment-shader\"]"});
  polymer.registerPolymerElement('s-fragment-shader', () => new SpectreFragmentShaderElement());

  polymer.setScopedCss('s-layer', {"s-layer":"[is=\"s-layer\"]"});
  polymer.registerPolymerElement('s-layer', () => new SpectreLayerElement());

  polymer.setScopedCss('s-line-primitive', {"s-line-primitive":"[is=\"s-line-primitive\"]"});
  polymer.registerPolymerElement('s-line-primitive', () => new SpectreLinePrimitiveElement());

  polymer.setScopedCss('s-material', {"s-material":"[is=\"s-material\"]"});
  polymer.registerPolymerElement('s-material', () => new SpectreMaterialElement());

  polymer.setScopedCss('s-material-constant', {"s-material-constant":"[is=\"s-material-constant\"]"});
  polymer.registerPolymerElement('s-material-constant', () => new SpectreMaterialConstantElement());

  polymer.setScopedCss('s-material-program', {"s-material-program":"[is=\"s-material-program\"]"});
  polymer.registerPolymerElement('s-material-program', () => new SpectreMaterialProgramElement());

  polymer.setScopedCss('s-model', {"s-model":"[is=\"s-model\"]"});
  polymer.registerPolymerElement('s-model', () => new SpectreModelElement());

  polymer.setScopedCss('s-post-effect', {"s-post-effect":"[is=\"s-post-effect\"]"});
  polymer.registerPolymerElement('s-post-effect', () => new SpectrePostEffectElement());

  polymer.setScopedCss('s-scene', {"s-scene":"[is=\"s-scene\"]"});
  polymer.registerPolymerElement('s-scene', () => new SpectreSceneElement());

  polymer.setScopedCss('s-transform', {"s-transform":"[is=\"s-transform\"]"});
  polymer.registerPolymerElement('s-transform', () => new SpectreTransformElement());

  polymer.setScopedCss('s-vertex-shader', {"s-vertex-shader":"[is=\"s-vertex-shader\"]"});
  polymer.registerPolymerElement('s-vertex-shader', () => new SpectreVertexShaderElement());

  var example = new DeclarativeExample(query(backBufferId), sceneId);
  example.gameLoop.pointerLock.lockOnClick = true;
  return example.initialize()
      .then((_) => example.load())
      .then((_) => example.start())
      .catchError((e) {
        print('Could not run ${example.name}: $e');
        print(e.stackTrace);
        window.alert('Could not run ${example.name}: $e. See console.');
      });
}