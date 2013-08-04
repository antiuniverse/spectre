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

library spectre_declarative_mesh;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative_main.dart';
import 'package:spectre/spectre_element.dart';
import 'package:spectre/src/spectre_declarative/material.dart';
import 'package:vector_math/vector_math.dart';

class SpectreMeshElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {
    'geometry-path': () =>
        new SpectreElementAttributeString('geometry-path',
                                          'assetpack://base.unitCube'),
    'material-id': () => new SpectreElementAttributeString('material-id', '')
  };
  final List<String> requiredSpectreAttributes = [ 'geometry-path',
                                                   'material-id' ];
  SpectreMaterialElement _material;
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
    if (!SpectreDeclarative.inited) {
      // Not ready to initialize.
      return;
    }
    // Initialize.
    super.init();
    _inputLayout = new InputLayout('SpectreMeshElement',
                                   SpectreDeclarative.graphicsDevice);
    _update();
  }

  void render() {
    super.render();
    _update();
    if (!_inputLayout.ready) {
      return;
    }
    var spectre = SpectreDeclarative.root;
    spectre.pushMaterial(_material);
    applyConstants();
    // Render self.
    var graphicsContext = SpectreDeclarative.graphicsContext;
    graphicsContext.setInputLayout(_inputLayout);
    _updateObjectTransformConstant(SpectreDeclarative.root.currentTransform);
    if (_indexed) {
      graphicsContext.setIndexedMesh(_mesh);
      graphicsContext.drawIndexedMesh(_mesh);
    } else {
      graphicsContext.setMesh(_mesh);
      graphicsContext.drawMesh(_mesh);
    }
    unapplyConstants();
    spectre.popMaterial();
  }

  void applyConstants() {
    if (_material == null) {
      return;
    }
    var l = findAllTagChildren('S-MATERIAL-CONSTANT');
    // Apply all constants, update stack.
    l.forEach((e) {
      _material.applyConstant(e.xtag, true);
    });
  }

  void unapplyConstants() {
    var l = findAllTagChildren('S-MATERIAL-CONSTANT').reversed;
    // Apply all constants, update stack.
    l.forEach((e) {
      _material.unapplyConstant(e.xtag);
    });
  }

  void _update() {
    assert(inited);
    var spectre = SpectreDeclarative.root;
    String geometryPath = spectreAttributes['geometry-path'].value;
    _mesh = SpectreDeclarative.assetManager['base.unitCube'];
    String materialId = spectreAttributes['material-id'].value;
    if (materialId != null) {
      var q = spectre.query(materialId);
      if (q != null) {
        _material = q.xtag;
      }
    }
    if (_mesh != null) {
      _inputLayout.mesh = _mesh;
    } else {
      _inputLayout.mesh = null;
    }
    if (_material != null) {
      _inputLayout.shaderProgram = _material.shaderProgram;
    } else {
      _inputLayout.shaderProgram = null;
    }
    _indexed = (_mesh is SingleArrayIndexedMesh);
  }

  void _updateObjectTransformConstant(Matrix4 T) {
    var graphicsContext = SpectreDeclarative.graphicsContext;
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['objectTransform'];
    if (uniform != null) {
      shader.updateUniform(uniform, T.storage);
    }
  }
}
