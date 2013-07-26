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

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math.dart';

import 'package:spectre/src/spectre_declarative/spectre_element.dart';

class SpectreLinePrimitiveElement extends SpectreElement {
  final Vector4 _color = new Vector4.zero();
  final Vector3 _a = new Vector3.zero();
  final Vector3 _b = new Vector3.zero();
  final Vector3 _c = new Vector3.zero();
  bool _depthEnabled = true;

  void _updateColor() {
    if (!parseVector4('color', _color)) {
      _color[0] = 0.0;
      _color[1] = 0.0;
      _color[2] = 0.0;
      _color[3] = 1.0;
    }
  }

  void _updateDepthEnabled() {
    _depthEnabled = attributes['depthless'] == null;
  }

  void _dispatchSphere(ddm) {
    if (!parseVector3('center', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    double radius = parseDouble('radius', 1.0);
    ddm.addSphere(_a, radius, _color, duration: 0.0,
                  depthEnabled: _depthEnabled);
  }

  void _dispatchLine(ddm) {
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
    ddm.addLine(_a, _b, _color, duration: 0.0, depthEnabled: _depthEnabled);
  }


  void _dispatchCross(ddm) {
    if (!parseVector3('center', _a)) {
      _a[0] = 0.0;
      _a[1] = 0.0;
      _a[2] = 0.0;
    }
    double size = parseDouble('radius', 1.0);
    ddm.addCross(_a, _color, size: size, duration: 0.0,
                 depthEnabled: _depthEnabled);
  }

  void _dispatchPlane(ddm) {
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
    double size = parseDouble('size', 1.0);
    ddm.addPlane(_a, _b, size, _color, duration: 0.0, depthEnabled: _depthEnabled);
  }

  void _dispatchCone(ddm) {
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
    double height = parseDouble('height', 1.0);
    double angle = parseDouble('angle', 0.785398163);
    ddm.addCone(_a, _b, height, angle, _color, duration: 0.0,
                depthEnabled: _depthEnabled);
  }

  void _dispatchArc(ddm) {
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
    double radius = parseDouble('radius', 1.0);
    double startAngle = parseDouble('startAngle', 0.0);
    double endAngle = parseDouble('endAngle', 0.785398163);
    ddm.addArc(_a, _b, radius, startAngle, endAngle, _color, duration: 0.0,
               depthEnabled: _depthEnabled);
  }

  void _dispatchCircle(ddm) {
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
    double radius = parseDouble('radius', 1.0);
    ddm.addCircle(_a, _b, radius, _color, duration: 0.0,
                  depthEnabled: _depthEnabled);
  }

  void _dispatchAABB(ddm) {
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
    ddm.addAABB(_a, _b, _color, duration: 0.0, depthEnabled: _depthEnabled);
  }

  void _dispatchTriangle(ddm) {
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
    ddm.addTriangle(_a, _b, _c, _color, duration: 0.0,
                    depthEnabled: _depthEnabled);
  }
  /*void addAxes(Matrix4 xform, num size,
               {num duration: 0.0, bool depthEnabled: true}) {
   */
  void dispatch(DebugDrawManager ddm) {
    String t = attributes['type'];
    if (t == null) {
      return;
    }
    _updateColor();
    //_updateDepthEnabled();
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
        _dispatchAABB(ddm);
      break;
      case 'triangle':
        _dispatchTriangle(ddm);
      break;
    }
  }
}
