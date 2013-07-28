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
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {};
  final List<String> requiredSpectreAttributes = [];
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
    _isSampler = false;
    _isUniform = false;
    _index = null;
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
    if (value == null) {
      // No value set.
      return;
    }
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    var graphicsContext = DeclarativeState.graphicsContext;
    switch (name) {
      case 'cullMode':
        currentMaterial.rasterizerState.cullMode = value;
        break;
      case 'frontFace':
        currentMaterial.rasterizerState.frontFace = value;
        break;
      case 'depthBias':
        currentMaterial.rasterizerState.depthBias = value;
        break;
      case 'slopeScaleDepthBias':
        currentMaterial.rasterizerState.slopeScaleDepthBias = value;
        break;
      case 'scissorTestEnabled':
        currentMaterial.rasterizerState.scissorTestEnabled = value;
        break;
    }
    graphicsContext.setRasterizerState(currentMaterial.rasterizerState);
  }

  void _updateRasterizerConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
    switch (name) {
      case 'cullMode':
        value = CullMode.parse(attributes['value']);
        break;
      case 'frontFace':
        value = FrontFace.parse(attributes['value']);
        break;
      case 'depthBias':
      case 'slopeScaleDepthBias':
        value = parseDouble('value', 0.0);
        break;
      case 'scissorTestEnabled':
        value = parseBool('value', false);
        break;
    }
  }

  void _applyDepthConstant(String name) {
    assert(inited);
    assert(_isDepthConstant(name));
    if (value == null) {
      // No value set.
      return;
    }
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    var graphicsContext = DeclarativeState.graphicsContext;
    switch (name) {
      case 'depthBufferEnabled':
        currentMaterial.depthState.depthBufferEnabled = value;
        break;
      case 'depthBufferWriteEnabled':
        currentMaterial.depthState.depthBufferWriteEnabled = value;
        break;
      case 'depthBufferFunction':
        currentMaterial.depthState.depthBufferFunction = value;
        break;
    }
    graphicsContext.setDepthState(currentMaterial.depthState);
  }

  void _updateDepthConstant(String name) {
    assert(inited);
    assert(_isDepthConstant(name));
    switch (name) {
      case 'depthBufferEnabled':
        value = parseBool('value', true);
        break;
      case 'depthBufferWriteEnabled':
        value = parseBool('value', true);
        break;
      case 'depthBufferFunction':
        value = CompareFunction.parse(attributes['value']);
        break;
    }
  }

  void _applyBlendConstant(String name) {
    assert(inited);
    assert(_isBlendConstant(name));
    if (value == null) {
      // No value set.
      return;
    }
    var currentMaterial = DeclarativeState.scene.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    var graphicsContext = DeclarativeState.graphicsContext;
    switch (name) {
      case 'enabled':
        currentMaterial.blendState.enabled = value;
        break;
      case 'blendFactorRed':
        currentMaterial.blendState.blendFactorRed = value;
        break;
      case 'blendFactorGreen':
        currentMaterial.blendState.blendFactorGreen = value;
        break;
      case 'blendFactorBlue':
        currentMaterial.blendState.blendFactorBlue = value;
        break;
      case 'blendFactorAlpha':
        currentMaterial.blendState.blendFactorAlpha = value;
        break;
      case 'alphaBlendOperation':
        currentMaterial.blendState.alphaBlendOperation = value;
        break;
      case 'alphaDestination':
        currentMaterial.blendState.alphaDestination = value;
        break;
      case 'alphaSourceBlend':
        currentMaterial.blendState.alphaSourceBlend = value;
        break;
      case 'colorBlendOperation':
        currentMaterial.blendState.colorBlendOperation = value;
        break;
      case 'colorDestinationBlend':
        currentMaterial.blendState.colorDestinationBlend = value;
        break;
      case 'colorSourceBlend':
        currentMaterial.blendState.colorSourceBlend = value;
        break;
      case 'writeRenderTargetRed':
        currentMaterial.blendState.writeRenderTargetRed = value;
        break;
      case 'writeRenderTargetGreen':
        currentMaterial.blendState.writeRenderTargetGreen = value;
        break;
      case 'writeRenderTargetBlue':
        currentMaterial.blendState.writeRenderTargetBlue = value;
        break;
      case 'writeRenderTargetAlpha':
        currentMaterial.blendState.writeRenderTargetAlpha = value;
        break;
    }
    graphicsContext.setBlendState(currentMaterial.blendState);
  }

  void _updateBlendConstant(String name) {
    assert(inited);
    assert(_isBlendConstant(name));
    switch (name) {
      case 'enabled':
        value = parseBool('value', true);
        break;
      case 'blendFactorRed':
      case 'blendFactorGreen':
      case 'blendFactorBlue':
      case 'blendFactorAlpha':
        value = parseDouble('value', 1.0);
        break;
      case 'alphaBlendOperation':
        value = BlendOperation.parse(attributes['value']);
        break;
      case 'alphaDestination':
        value = Blend.parse(attributes['value']);
        break;
      case 'alphaSourceBlend':
        value = Blend.parse(attributes['value']);
        break;
      case 'colorBlendOperation':
        value = BlendOperation.parse(attributes['value']);
        break;
      case 'colorDestinationBlend':
        value = Blend.parse(attributes['value']);
        break;
      case 'colorSourceBlend':
        value = Blend.parse(attributes['value']);
        break;
      case 'writeRenderTargetRed':
      case 'writeRenderTargetGreen':
      case 'writeRenderTargetBlue':
      case 'writeRenderTargetAlpha':
        value = parseBool('value', true);
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
