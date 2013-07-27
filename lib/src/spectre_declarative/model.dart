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
  ShaderProgram _shaderProgram;
  InputLayout _inputLayout;

  void _update() {
    if (SpectreElement.graphicsDevice == null) {
      return;
    }
    if (_inputLayout == null) {
      _inputLayout = new InputLayout('SpectreModelElement',
                                     SpectreElement.graphicsDevice);
    }
    _mesh = SpectreElement.assetManager['base.unitCube'];
    _shaderProgram = SpectreElement.assetManager['base.simpleShader'];
    _inputLayout.mesh = _mesh;
    _inputLayout.shaderProgram = _shaderProgram;
    _indexed = (_mesh is SingleArrayIndexedMesh);
  }

  void _updateCameraConstants(Camera camera) {
    var graphicsContext = SpectreElement.graphicsContext;
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

  render() {
    _update();
    var scene = SpectreElement.scene;
    var graphicsDevice = SpectreElement.graphicsDevice;
    graphicsDevice.context.setInputLayout(_inputLayout);
    graphicsDevice.context.setShaderProgram(_shaderProgram);
    _updateCameraConstants(scene.currentCamera);
    _updateObjectTransformConstant(scene.currentTransform);
    if (_indexed) {
      graphicsDevice.context.setIndexedMesh(_mesh);
      graphicsDevice.context.drawIndexedMesh(_mesh);
    } else {
      graphicsDevice.context.setMesh(_mesh);
      graphicsDevice.context.drawMesh(_mesh);
    }
  }

  unapply() {
    // NOP.
  }
}
