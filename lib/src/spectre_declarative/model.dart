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
import 'package:vector_math/vector_math.dart';

import 'package:spectre/src/spectre_declarative/element.dart';

class SpectreModelElement extends SpectreElement {
  SpectreMesh _mesh;
  bool _indexed;
  InputLayout _inputLayout;

  void _update() {
    var scene = SpectreElement.scene;
    if (SpectreElement.graphicsDevice == null) {
      return;
    }
    if (_inputLayout == null) {
      _inputLayout = new InputLayout('SpectreModelElement',
                                     SpectreElement.graphicsDevice);
    }
    var material = scene.currentMaterial;
    _mesh = SpectreElement.assetManager['base.unitCube'];
    _inputLayout.mesh = _mesh;
    _inputLayout.shaderProgram = material.shaderProgram;
    _indexed = (_mesh is SingleArrayIndexedMesh);
  }

  void _updateObjectTransformConstant(Matrix4 T) {
    var graphicsContext = SpectreElement.graphicsContext;
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['objectTransform'];
    if (uniform != null) {
      shader.updateUniform(uniform, T.storage);
    }
  }

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
    _update();
  }

  removed() {
    super.removed();
    _inputLayout.dispose();
    _inputLayout = null;
  }

  apply() {
    // NOP.
  }

  void applyConstants() {
    var scene = SpectreElement.scene;
    var material = scene.currentMaterial;
    var l = queryAll('s-material-constant');
    // Apply all constants, update stack.
    l.forEach((e) {
      e.xtag.render();
    });
  }

  void unapplyConstants() {
    var scene = SpectreElement.scene;
    var material = scene.currentMaterial;
    var l = queryAll('s-material-constant').reversed;
    l.forEach((e) => material.unapplyConstant(e.xtag));
  }

  render() {
    var scene = SpectreElement.scene;
    if (scene == null) {
      return;
    }
    _update();
    applyConstants();
    var graphicsDevice = SpectreElement.graphicsDevice;
    graphicsDevice.context.setInputLayout(_inputLayout);
    _updateObjectTransformConstant(scene.currentTransform);
    if (_indexed) {
      graphicsDevice.context.setIndexedMesh(_mesh);
      graphicsDevice.context.drawIndexedMesh(_mesh);
    } else {
      graphicsDevice.context.setMesh(_mesh);
      graphicsDevice.context.drawMesh(_mesh);
    }
    unapplyConstants();
  }

  unapply() {
    // NOP.
  }
}
