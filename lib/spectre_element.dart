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

abstract class SpectreElement extends PolymerElement {
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

  bool parseBool(String attributeName, bool b) {
    var a = attributes[attributeName];
    if (a == null) {
      return b;
    }
    bool l;
    try {
      l = JSON.parse(a);
    } catch (e) {
      return b;
    }
    return l;
  }

  void created() {
    super.created();
    //print('created $this');
  }

  void inserted() {
    super.inserted();
    //print('inserted $this');
  }

  void removed() {
    super.removed();
    //print('removed $this');
  }

  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    print('$name changed from $oldValue to $newValue');
  }

  List findAllTagChildren(String tag) {
    List l = new List();
    children.forEach((e) {
      if (e.tagName == tag) {
        l.add(e);
      }
    });
    return l;
  }

  void applyChildren() {
    children.forEach((e) {
      if (e.xtag is SpectreElement) {
        e.xtag.apply();
      }
    });
  }

  void renderChildren() {
    children.forEach((e) {
      if (e.xtag is SpectreElement) {
        e.xtag.render();
      }
    });
  }

  bool _inited = false;
  bool get inited => _inited;

  /// All elements *must* override the following methods:
  ///
  /// * [init]
  /// * [apply]
  /// * [render]
  ///

  /// If element is initialized, do nothing.
  /// If DeclarativeState.inited is false, do nothing.
  /// Initialize element.
  void init() {
    _inited = true;
  }
  /// Apply this object to the GPU pipeline.
  void apply() {
    assert(_inited);
  }
  /// Render this object.
  void render() {
    assert(_inited);
  }
}
