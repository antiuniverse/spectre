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

library debug_draw_main;

import 'dart:async';
import 'dart:html';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:asset_pack/asset_pack.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_example_ui.dart';
import 'package:vector_math/vector_math.dart';

import 'package:polymer/polymer.dart' as polymer;

void main() {
  polymer.setScopedCss('s-camera', {"s-camera":"[is=\"s-camera\"]"});
  polymer.registerPolymerElement('s-camera', () => new SpectreCameraElement());
  polymer.setScopedCss('s-layer', {"s-layer":"[is=\"s-layer\"]"});
  polymer.registerPolymerElement('s-layer', () => new SpectreLayerElement());
  polymer.setScopedCss('s-line-primitive', {"s-line-primitive":"[is=\"s-line-primitive\"]"});
  polymer.registerPolymerElement('s-line-primitive', () => new SpectreLinePrimitiveElement());
  polymer.setScopedCss('s-material', {"s-material":"[is=\"s-material\"]"});
  polymer.registerPolymerElement('s-material', () => new SpectreMaterialElement());
  polymer.setScopedCss('s-model', {"s-model":"[is=\"s-model\"]"});
  polymer.registerPolymerElement('s-model', () => new SpectreModelElement());
  polymer.setScopedCss('s-post-effect', {"s-post-effect":"[is=\"s-post-effect\"]"});
  polymer.registerPolymerElement('s-post-effect', () => new SpectrePostEffectElement());
  polymer.setScopedCss('s-scene', {"s-scene":"[is=\"s-scene\"]"});
  polymer.registerPolymerElement('s-scene', () => new SpectreSceneElement());
  polymer.setScopedCss('s-transform', {"s-transform":"[is=\"s-transform\"]"});
  polymer.registerPolymerElement('s-transform', () => new SpectreTransformElement());

  var example = new DeclarativeExample(query('#backBuffer'));
  example.gameLoop.pointerLock.lockOnClick = true;
  runExample(example);
}