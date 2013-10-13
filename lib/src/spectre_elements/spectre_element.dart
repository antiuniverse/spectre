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

import 'dart:convert';
import 'dart:html';
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/polymer_expressions.dart';
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

class SpectreElementAttributeInt extends SpectreElementAttribute<int> {
  SpectreElementAttributeInt(String key, int defaultValue)
      : super(key, defaultValue);
  void parse(String value) {
    reset();
    if (value == null) {
      return;
    }
    try {
      _value = int.parse(value);
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
      List l = JSON.decode(value);
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
      List l = JSON.decode(value);
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

@CustomTag('s-element')
class SpectreElement extends PolymerElement {
  static PolymerExpressions _spectreSyntax = new PolymerExpressions(globals: {
    'Vector2': (x, y) {
      return new Vector2(x, y);
    },
    'Vector3': (x, y, z) {
      print('Evaluating Vector3($x, $y, $z)');
      return new Vector3(x, y, z);
    },
    'Vector4': (x, y, z, w) {
      return new Vector4(x, y, z, w);
    },
    'ensureDouble': (x) {
      return x.toDouble();
    },
    'ensureInt': (x) {
      return x.toInt();
    }
  });

  static Vector4 _vector4Handler(String value, Object defaultValue) {
    try {
      List l = JSON.decode(value);
      assert(l.length == 4);
      return new Vector4(l[0], l[1], l[2], l[3]);
    } catch (_) {
      return defaultValue;
    }
  }

  static Vector3 _vector3Handler(String value, Object defaultValue) {
    try {
      List l = JSON.decode(value);
      assert(l.length == 3);
      return new Vector3(l[0], l[1], l[2]);
    } catch (_) {
      return defaultValue;
    }
  }

  static Vector2 _vector2Handler(String value, Object defaultValue) {
    try {
      List l = JSON.decode(value);
      assert(l.length == 2);
      return new Vector2(l[0], l[1]);
    } catch (_) {
      return defaultValue;
    }
  }

  static final _typeHandlers = () {
    var m = new Map();
    m[const Symbol('vector_math.Vector4')] = _vector4Handler;
    m[const Symbol('vector_math.Vector3')] = _vector3Handler;
    m[const Symbol('vector_math.Vector2')] = _vector2Handler;
    return m;
  }();

  Object deserializeValue(String value, Object defaultValue, TypeMirror type) {
    var handler = _typeHandlers[type.qualifiedName];
    if (handler != null) {
      return handler(value, defaultValue);
    }
    return super.deserializeValue(value, defaultValue, type);
  }

  bool get applyAuthorStyles => true;
  DocumentFragment instanceTemplate(Element template) =>
      template.createInstance(this, _spectreSyntax);

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

  void attributeChanged(String name, String oldValue) {
    super.attributeChanged(name, oldValue);
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

  void render() {
    assert(_inited);
  }
}