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

abstract class SpectreElementAttribute<E> {
  final String name;
  final E _defaultValue;
  E _value;
  E get value => _value;
  SpectreElementAttribute(this.name, this._defaultValue) {
    reset();
  }

  void reset() {
    _value = _defaultValue;
  }

  // Parse the value.
  void parse(String value);

  void removed() {}
}

class SpectreElementAttributeBool extends SpectreElementAttribute<bool> {
  SpectreElementAttributeBool(String key, bool defaultValue)
      : super(key, defaultValue);
  void parse(String value) {
    reset();
    if (value == null) {
      return;
    }
  }
}

class SpectreElementAttributeDouble extends SpectreElementAttribute<double> {
  SpectreElementAttributeDouble(String key, double defaultValue)
      : super(key, defaultValue);
  void parse(String value) {
    reset();
    if (value == null) {
      return;
    }
    try {
      _value = double.parse(value);
    } catch (e) {
      return;
    }
  }
}

class SpectreElementAttributeString extends SpectreElementAttribute<String> {
  SpectreElementAttributeString(String key, String defaultValue)
      : super(key, defaultValue);
  void parse(String value) {
    if (value == null) {
      reset();
      return;
    }
    _value = value;
  }
}

class SpectreElementAttributeVector3 extends SpectreElementAttribute<Vector3> {
  SpectreElementAttributeVector3(String key, Vector3 defaultValue)
      : super(key, defaultValue);
  void parse(String value) {
    if (value == null) {
      reset();
      return;
    }
    try {
      List l = JSON.parse(value);
      assert(l.length == 3);
      if (_value == _defaultValue) {
        _value = new Vector3.zero();
      }
      _value[0] = l[0];
      _value[1] = l[1];
      _value[2] = l[2];
    } catch (e) {
      reset();
      return;
    }
  }
}

class SpectreElementAttributeVector4 extends SpectreElementAttribute<Vector4> {
  SpectreElementAttributeVector4(String key, Vector3 defaultValue)
      : super(key, defaultValue);
  void parse(String value) {
    if (value == null) {
      reset();
      return;
    }
    try {
      List l = JSON.parse(value);
      assert(l.length == 3);
      if (_value == _defaultValue) {
        _value = new Vector4.zero();
      }
      _value[0] = l[0];
      _value[1] = l[1];
      _value[2] = l[2];
      _value[3] = l[3];
    } catch (e) {
      reset();
      return;
    }
  }
}

typedef SpectreElementAttribute AttributeConstructor();

abstract class SpectreElement extends PolymerElement {
  final Map<String, SpectreElementAttribute> spectreAttributes =
      new Map<String, SpectreElementAttribute>();
  Map<String, AttributeConstructor> get spectreAttributeDefinitions;
  List<String> get requiredSpectreAttributes;

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
    print('created $this');
  }

  void inserted() {
    super.inserted();
    refreshAttributes();
    print('inserted $this');
  }

  void refreshAttributes() {
    spectreAttributes.clear();
    requiredSpectreAttributes.forEach((k) {
      AttributeConstructor constructor = spectreAttributeDefinitions[k];
      if (constructor != null) {
        var attribute = constructor();
        spectreAttributes[k] = attribute;
      }
    });
    attributes.forEach((k, v) {
      var attribute = spectreAttributes[k];
      if (attribute != null) {
        attribute.parse(v);
        return;
      }
      AttributeConstructor constructor = spectreAttributeDefinitions[k];
      if (constructor != null) {
        var attribute = constructor();
        attribute.parse(v);
        spectreAttributes[k] = attribute;
      }
    });
  }

  void removed() {
    super.removed();
    print('removed $this');
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

  void pushChildren() {
    children.forEach((e) {
      if (e.xtag is SpectreElement) {
        e.xtag.push();
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

  void popChildren() {
    children.forEach((e) {
      if (e.xtag is SpectreElement) {
        e.xtag.pop();
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

  void render() {
    assert(_inited);
  }
}
