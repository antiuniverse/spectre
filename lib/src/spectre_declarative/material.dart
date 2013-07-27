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

library spectre_declarative_material;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math.dart';

import 'package:spectre/src/spectre_declarative/element.dart';
import 'package:spectre/src/spectre_declarative/material_constant.dart';

class SpectreMaterialElement extends SpectreElement {
  ShaderProgram _shaderProgram;
  DepthState _dState;
  RasterizerState _rState;
  BlendState _bState;
  final Map<String, List<SpectreMaterialConstantElement>> _constantStack = new
      Map<String, List<SpectreMaterialConstantElement>>();

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
  }

  removed() {
    super.removed();
  }

  apply() {
  }

  render() {
  }

  unapply() {
  }

  _applyConstant(SpectreMaterialConstantElement constant,
                 bool updateStack) {
    String name = constant.name;
    constant.apply();
    if (updateStack) {
      _constantStack[name].add(constant);
    }
  }

  _unapplyConstant(SpectreMaterialConstantElement constant) {
    String name = constant.name;
    var stack = _constantStack[name];
    assert(stack != null);
    assert(constant == stack.last);
    stack.removeLast();
    var o = stack.last;
    if (o != null) {
      // Set to old value, do not update stack.
      _applyConstant(o, false);
    }
  }

  _applyConstants() {
    var l = queryAll('s-material-constant');
    // Apply all constants, update stack.
    l.forEach((e) => _applyConstant(e.xtag, true));
  }

  _unapplyConstants() {
    var l = queryAll('s-material-constant');
    // Unapply constants in revers order.
    l.reversed.forEach((e) => _unapplyConstant(e.xtag));
  }
}
