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

library spectre_line_primitive_element;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:vector_math/vector_math.dart';

@CustomTag('s-line-primitive')
class SpectreLinePrimitiveElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {};
  final List<String> requiredSpectreAttributes = [];
  final Vector4 _color = new Vector4.zero();
  final Vector3 _a = new Vector3.zero();
  final Vector3 _b = new Vector3.zero();
  final Vector3 _c = new Vector3.zero();
  double _radius = 0.0;
  double _angleA = 0.0;
  double _angleB = 0.0;
  bool _depthEnabled = true;

  void created() {
    super.created();
  }

  void inserted() {
    super.inserted();
    init();
  }

  void removed() {
    super.removed();
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
    update();
  }

  void render() {
    dispatch(SpectreDeclarative.debugDrawManager);
  }

  bool parseVector3(String attributeName, Vector3 vec) {
    var a = attributes[attributeName];
    if (a == null) {
      return false;
    }
    var l;
    try {
      l = JSON.parse(a);
    } catch (e) {
      return false;
    }
    try {
      vec[0] = l[0].toDouble();
      vec[1] = l[1].toDouble();
      vec[2] = l[2].toDouble();
    } catch (e) {
      return false;
    }
    return true;
  }

  bool parseVector4(String attributeName, Vector4 vec) {
    var a = attributes[attributeName];
    if (a == null) {
      return false;
    }
    var l;
    try {
      l = JSON.parse(a);
    } catch (e) {
      return false;
    }
    try {
      vec[0] = l[0].toDouble();
      vec[1] = l[1].toDouble();
      vec[2] = l[2].toDouble();
      vec[3] = l[3].toDouble();
    } catch (e) {
      return false;
    }
    return true;
  }

  double parseDouble(String attributeName, double d) {
    var a = attributes[attributeName];
    if (a == null) {
      return d;
    }
    var l;
    try {
      l = double.parse(a);
    } catch (e) {
      return d;
    }
    return l;
  }

  void _updateColor() {
    if (!parseVector4('color', _color)) {
      _color[0] = 0.0;
      _color[1] = 0.0;
      _color[2] = 0.0;
      _color[3] = 1.0;
    }
  }

  void _updateSphere() {
    if (!parseVector3('center', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    _radius = parseDouble('radius', 1.0);
  }

  void _dispatchSphere(ddm) {
    ddm.addSphere(_a, _radius, _color, duration: 0.0,
                  depthEnabled: _depthEnabled);
  }

  void _updateLine() {
    if (!parseVector3('start', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('end', _b)) {
      _b[0] = 1.0;
      _b[1] = 1.0;
      _b[2] = 1.0;
    }
  }

  void _dispatchLine(ddm) {
    ddm.addLine(_a, _b, _color, duration: 0.0, depthEnabled: _depthEnabled);
  }

  void _updateCross() {
    if (!parseVector3('center', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    _radius = parseDouble('radius', 1.0);
  }

  void _dispatchCross(ddm) {
    ddm.addCross(_a, _color, size: _radius, duration: 0.0,
                 depthEnabled: _depthEnabled);
  }

  void _updatePlane() {
    if (!parseVector3('normal', _a)) {
      _a[0] = 1.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('center', _b)) {
      _b[0] = 0.0;
      _b[1] = 0.0;
      _b[2] = 0.0;
    }
    _radius = parseDouble('size', 1.0);
  }

  void _dispatchPlane(ddm) {
    ddm.addPlane(_a, _b, _radius, _color, duration: 0.0, depthEnabled: _depthEnabled);
  }

  void _updateCone() {
    if (!parseVector3('apex', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('direction', _b)) {
      _b[0] = 1.0;
      _b[1] = 0.0;
      _b[2] = 0.0;
    }
    _radius = parseDouble('height', 1.0);
    _angleA = parseDouble('angle', 0.785398163);
  }

  void _dispatchCone(ddm) {
    ddm.addCone(_a, _b, _radius, _angleA, _color, duration: 0.0,
                depthEnabled: _depthEnabled);
  }

  void _updateArc() {
    if (!parseVector3('center', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('normal', _b)) {
      _b[0] = 1.0;
      _b[1] = 0.0;
      _b[2] = 0.0;
    }
    _radius = parseDouble('radius', 1.0);
    _angleA = parseDouble('startAngle', 0.0);
    _angleB = parseDouble('endAngle', 0.785398163);
  }

  void _dispatchArc(ddm) {

    ddm.addArc(_a, _b, _radius, _angleA, _angleB, _color, duration: 0.0,
               depthEnabled: _depthEnabled);
  }

  void _updateCircle() {
    if (!parseVector3('center', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('normal', _b)) {
      _b[0] = 1.0;
      _b[1] = 0.0;
      _b[2] = 0.0;
    }
    _radius = parseDouble('radius', 1.0);
  }

  void _dispatchCircle(ddm) {
    ddm.addCircle(_a, _b, _radius, _color, duration: 0.0,
                  depthEnabled: _depthEnabled);
  }

  void _updateAabb() {
    if (!parseVector3('min', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('max', _b)) {
      _b[0] = 1.0;
      _b[1] = 1.0;
      _b[2] = 1.0;
    }
  }

  void _dispatchAabb(ddm) {
    ddm.addAABB(_a, _b, _color, duration: 0.0, depthEnabled: _depthEnabled);
  }

  void _updateTriangle() {
    if (!parseVector3('a', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    if (!parseVector3('b', _b)) {
      _b[0] = 0.0;
      _b[1] = 1.0;
      _b[2] = 1.0;
    }
    if (!parseVector3('c', _c)) {
      _c[0] = 0.0;
      _c[1] = 1.0;
      _c[2] = 0.0;
    }
  }

  void _dispatchTriangle(ddm) {
    ddm.addTriangle(_a, _b, _c, _color, duration: 0.0,
                    depthEnabled: _depthEnabled);
  }

  void dispatch(DebugDrawManager ddm) {
    String t = attributes['type'];
    if (t == null) {
      return;
    }
    switch (t) {
      case 'sphere':
        _dispatchSphere(ddm);
      break;
      case 'line':
        _dispatchLine(ddm);
      break;
      case 'cross':
        _dispatchCross(ddm);
      break;
      case 'plane':
        _dispatchPlane(ddm);
      break;
      case 'cone':
        _dispatchCone(ddm);
      break;
      case 'arc':
        _dispatchArc(ddm);
      break;
      case 'circle':
        _dispatchCircle(ddm);
      break;
      case 'aabb':
        _dispatchAabb(ddm);
      break;
      case 'triangle':
        _dispatchTriangle(ddm);
      break;
    }
  }

  void update() {
    String t = attributes['type'];
    if (t == null) {
      return;
    }
    _updateColor();
    switch (t) {
      case 'sphere':
        _updateSphere();
      break;
      case 'line':
        _updateLine();
      break;
      case 'cross':
        _updateCross();
      break;
      case 'plane':
        _updatePlane();
      break;
      case 'cone':
        _updateCone();
      break;
      case 'arc':
        _updateArc();
      break;
      case 'circle':
        _updateCircle();
      break;
      case 'aabb':
        _updateAabb();
      break;
      case 'triangle':
        _updateTriangle();
      break;
    }
  }
}
