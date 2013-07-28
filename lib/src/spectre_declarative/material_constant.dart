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

library spectre_declarative_material_constant;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative_main.dart';
import 'package:spectre/spectre_element.dart';
import 'package:vector_math/vector_math.dart';

/*
<s-material-constant name="sourceR" texture="assetpack://asset.pack.blah" minification="mipmap">
</s-material-constant>
<s-material-constant name="cameraView" data="[]">
</s-material-constant>
<s-material-constant name="blend.source" value="">
</s-material-constant>
<s-material-constant name="depth.func" value="">
</s-material-constant-uniform>
*/

class SpectreMaterialConstantElement extends SpectreElement {
  String name;
  SamplerState _sampler;
  SpectreTexture _texture;
  dynamic index;
  bool _isSampler = false;

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
    init();
  }

  void init() {
    if (inited) {
      // Already initialized.
      return;
    }
    if (!DeclarativeState.inited) {
      // Not ready to initialize.
      return;
    }
    // Initialize.
    super.init();
    _sampler = new SamplerState('SpectreMaterialConstantElement',
                                DeclarativeState.graphicsDevice);
    _update();
  }

  removed() {
    super.removed();
  }

  apply() {
    super.apply();
    _update();
    var scene = DeclarativeState.scene;
    var graphicsContext = DeclarativeState.graphicsContext;
    if (index == null) {
      return;
    }
    if (_isSampler) {
      graphicsContext.setTexture(index, _texture);
      graphicsContext.setSampler(index, _sampler);
    }
  }

  render() {
    super.render();
    _update();
    var scene = DeclarativeState.scene;
    var currentMaterial = scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    currentMaterial.applyConstant(this, true);
  }

  void _update() {
    assert(inited);
    name = attributes['name'];
    if (name == null) {
      return;
    }
    var graphicsDevice = DeclarativeState.graphicsDevice;
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    var sampler = currentMaterial.shaderProgram.samplers[name];
    _isSampler = sampler != null;
    if (_isSampler) {
      index = sampler.textureUnit;
      _texture = DeclarativeState.getAsset(attributes['texture']);
      // TODO(johnmccutchan): Update sampler attributes.
    } else {
      index = sampler.location;
    }
  }
}
