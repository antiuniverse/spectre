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

library spectre_declarative_model;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative_main.dart';
import 'package:spectre/spectre_element.dart';
import 'package:vector_math/vector_math.dart';

class SpectreModelElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {};
  final List<String> requiredSpectreAttributes = [];
  SpectreMesh _mesh;
  bool _indexed = false;
  InputLayout _inputLayout;

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
    init();
  }

  removed() {
    super.removed();
    _inputLayout.dispose();
    _inputLayout = null;
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
    _inputLayout = new InputLayout('SpectreModelElement',
                                   DeclarativeState.graphicsDevice);
    _update();
  }

  apply() {
    super.apply();
    // NOP.
  }

  render() {
    _update();
    super.render();
    applyConstants();
    var graphicsContext = DeclarativeState.graphicsContext;
    graphicsContext.setInputLayout(_inputLayout);
    _updateObjectTransformConstant(DeclarativeState.scene.currentTransform);
    if (_indexed) {
      graphicsContext.setIndexedMesh(_mesh);
      graphicsContext.drawIndexedMesh(_mesh);
    } else {
      graphicsContext.setMesh(_mesh);
      graphicsContext.drawMesh(_mesh);
    }
    unapplyConstants();
  }

  void applyConstants() {
    var scene = DeclarativeState.scene;
    var material = scene.currentMaterial;
    var l = findAllTagChildren('S-MATERIAL-CONSTANT');
    // Apply all constants, update stack.
    l.forEach((e) {
      var elem = e.xtag;
      material.applyConstant(elem, true);
    });
  }

  void unapplyConstants() {
    var scene = DeclarativeState.scene;
    var material = scene.currentMaterial;
    var l = findAllTagChildren('S-MATERIAL-CONSTANT').reversed;
    l.forEach((e) {
      var elem = e.xtag;
      material.unapplyConstant(elem);
    });
  }

  void _update() {
    assert(inited);
    var scene = DeclarativeState.scene;
    var material = scene.currentMaterial;
    if (material == null) {
      return;
    }
    _mesh = DeclarativeState.assetManager['base.unitCube'];
    _inputLayout.mesh = _mesh;
    _inputLayout.shaderProgram = material.shaderProgram;
    _indexed = (_mesh is SingleArrayIndexedMesh);
  }

  void _updateObjectTransformConstant(Matrix4 T) {
    var graphicsContext = DeclarativeState.graphicsContext;
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['objectTransform'];
    if (uniform != null) {
      shader.updateUniform(uniform, T.storage);
    }
  }
}
