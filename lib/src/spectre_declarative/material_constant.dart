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

class SpectreMaterialConstantElement extends SpectreElement {
  String name;

  // State constants
  dynamic value;

  // Texture constants.
  bool _isSampler = false;
  SamplerState _sampler;
  SpectreTexture _texture;
  dynamic _index;

  SamplerState get sampler => _sampler;
  SpectreTexture get texture => _texture;

  // Uniform constants.
  bool _isUniform = false;
  // _index

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
    if (_isSampler) {
      _applySampler();
    } else if (_isUniform) {
      _applyUniform();
    } else if (_isRasterizerConstant(name)) {
      _applyRasterizerConstant(name);
    } else if (_isDepthConstant(name)) {
      _applyDepthConstant(name);
    } else if (_isBlendConstant(name)) {
      _applyBlendConstant(name);
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
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    if (_isRasterizerConstant(name)) {
      _updateRasterizerConstant(name);
    } else if (_isDepthConstant(name)) {
      _updateDepthConstant(name);
    } else if (_isBlendConstant(name)) {
      _updateBlendConstant(name);
    } else {
      _index = null;
      var sampler = currentMaterial.shaderProgram.samplers[name];
      _isSampler = sampler != null;
      if (sampler != null) {
        _updateSampler(sampler);
      } else {
        var uniform = currentMaterial.shaderProgram.uniforms[name];
        _isUniform = uniform != null;
        if (uniform != null) _updateUniform(uniform);
      }
    }
  }

  void _applySampler() {
    if (_index == null) {
      return;
    }
    assert(_isSampler);
    var graphicsContext = DeclarativeState.graphicsContext;
    graphicsContext.setTexture(_index, _texture);
    graphicsContext.setSampler(_index, _sampler);
  }

  void _updateSampler(ShaderProgramSampler sampler) {
    _index = sampler.textureUnit;
    _texture = DeclarativeState.getAsset(attributes['texture']);
  }

  void _applyUniform() {
  }

  void _updateUniform(ShaderProgramUniform uniform) {
  }

  void _applyRasterizerConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
  }

  void _updateRasterizerConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    switch (name) {
      case 'cullMode':
        break;
      case 'frontFace':
        break;
      case 'depthBias':
        break;
      case 'slopeScaleDepthBias':
        break;
      case 'scissorTestEnabled':
        break;
    }
  }

  void _applyDepthConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
  }

  void _updateDepthConstant(String name) {
    assert(inited);
    assert(_isDepthConstant(name));
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    switch (name) {
      case 'depthBufferEnabled':
        break;
      case 'depthBufferWriteEnabled':
        break;
      case 'depthBufferFunction':
        break;
    }
  }

  void _applyBlendConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
  }

  void _updateBlendConstant(String name) {
    assert(inited);
    assert(_isBlendConstant(name));
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    switch (name) {
      case 'enabled':
        break;
      case 'blendFactorRed':
        break;
      case 'blendFactorGreen':
        break;
      case 'blendFactorBlue':
        break;
      case 'blendFactorAlpha':
        break;
      case 'alphaBlendOperation':
        break;
      case 'alphaDestination':
        break;
      case 'alphaSourceBlend':
        break;
      case 'colorBlendOperation':
        break;
      case 'colorDestinationBlend':
        break;
      case 'colorSourceBlend':
        break;
      case 'writeRenderTargetRed':
        break;
      case 'writeRenderTargetGreen':
        break;
      case 'writeRenderTargetBlue':
        break;
      case 'writeRenderTargetAlpha':
        break;
    }
  }

  static bool _isRasterizerConstant(String name) {
    List<String> rasterizerConstants = ['cullMode', 'frontFace', 'depthBias',
                                        'slopeScaleDepthBias',
                                        'scissorTestEnabled'];
    for (var i = 0; i < rasterizerConstants.length; i++) {
      if (name == rasterizerConstants[i]) {
        return true;
      }
    }
    return false;
  }

  static bool _isDepthConstant(String name) {
    List<String> depthConstants = ['depthBufferEnabled',
                                   'depthBufferWriteEnabled',
                                   'depthBufferFunction'];
    for (var i = 0; i < depthConstants.length; i++) {
      if (name == depthConstants[i]) {
        return true;
      }
    }
    return false;
  }

  static bool _isBlendConstant(String name) {
    List<String> blendConstant = ['enabled',
                                  'blendFactorRed',
                                  'blendFactorGreen',
                                  'blendFactorBlue',
                                  'blendFactorAlpha',
                                  'alphaBlendOperation',
                                  'alphaDestination',
                                  'alphaSourceBlend',
                                  'colorBlendOperation',
                                  'colorDestinationBlend',
                                  'colorSourceBlend',
                                  'writeRenderTargetRed',
                                  'writeRenderTargetGreen',
                                  'writeRenderTargetBlue',
                                  'writeRenderTargetAlpha'];
    for (var i = 0; i < blendConstant.length; i++) {
      if (name == blendConstant[i]) {
        return true;
      }
    }
    return false;
  }
}
