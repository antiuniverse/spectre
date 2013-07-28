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

library spectre_declarative_material;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_element.dart';
import 'package:spectre/spectre_declarative_main.dart';
import 'package:spectre/src/spectre_declarative/material_constant.dart';
import 'package:vector_math/vector_math.dart';

class SpectreMaterialElement extends SpectreElement {
  final DepthState depthState = new DepthState();
  final RasterizerState rasterizerState = new RasterizerState();
  final BlendState blendState = new BlendState.alphaBlend();
  final Map<String, List<SpectreMaterialConstantElement>> _constantStack = new
      Map<String, List<SpectreMaterialConstantElement>>();

  ShaderProgram _shaderProgram;
  ShaderProgram get shaderProgram => _shaderProgram;

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
    init();
  }

  removed() {
    super.removed();
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
    _update();
  }

  apply() {
    super.apply();
    if (_shaderProgram == null) {
      return;
    }
    var graphicsContext = DeclarativeState.graphicsContext;
    graphicsContext.setShaderProgram(_shaderProgram);
    graphicsContext.setDepthState(depthState);
    graphicsContext.setRasterizerState(rasterizerState);
    graphicsContext.setBlendState(blendState);
  }

  render() {
    super.render();
    if (_shaderProgram == null) {
      return;
    }
    var scene = DeclarativeState.scene;
    scene.pushMaterial(this);
    _updateCameraConstants(scene.currentCamera);
    renderChildren();
    _unapplyConstants();
    scene.popMaterial();
  }

  void applyConstant(SpectreMaterialConstantElement constant,
                     bool updateStack) {
    String name = constant.name;
    if (name == null) {
      return;
    }
    constant.apply();
    if (updateStack) {
      var l = _constantStack[name];
      if (l == null) {
        l = new List<SpectreMaterialConstantElement>();
        _constantStack[name] = l;
      }
      l.add(constant);
    }
  }

  void unapplyConstant(SpectreMaterialConstantElement constant) {
    String name = constant.name;
    if (name == null) {
      return;
    }
    var stack = _constantStack[name];
    assert(stack != null);
    assert(stack.length > 0);
    assert(constant.name == stack.last.name);
    stack.removeLast();
    if (stack.length == 0) {
      return;
    }
    var o = stack.last;
    if (o != null) {
      // Set to old value, do not update stack.
      applyConstant(o, false);
    }
  }

  _applyConstants() {
    var l = findAllTagChildren('S-MATERIAL-CONSTANT');
    // Apply all constants, update stack.
    l.forEach((e) {
      applyConstant(e.xtag, true);
    });
  }

  _unapplyConstants() {
    var l = findAllTagChildren('S-MATERIAL-CONSTANT');
    // Unapply constants in revers order.
    l.reversed.forEach((e) {
      unapplyConstant(e.xtag);
    });
  }

  void _updateCameraConstants(Camera camera) {
    var graphicsContext = DeclarativeState.graphicsContext;
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

  // Will go away once attribute change notifications are hooked up.
  void _update() {
    assert(inited);
    _shaderProgram = DeclarativeState.getAsset(attributes['shader']);
  }
}
