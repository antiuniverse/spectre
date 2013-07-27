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

library spectre_element;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:vector_math/vector_math.dart';

class SpectreElement extends PolymerElement {
  static var scene;
  static var debugDrawManager;
  static var graphicsContext;
  static var graphicsDevice;
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

  void created() {
    super.created();
    print('created $this');
  }

  void inserted() {
    super.inserted();
    print('inserted $this');
  }

  void removed() {
    super.removed();
    print('removed $this');
  }

  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    print('$name changed from $oldValue to $newValue');
  }

  void render() {
  }
}
