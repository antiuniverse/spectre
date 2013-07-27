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

library spectre_declarative_material_constant;

import 'dart:json' as JSON;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math.dart';

import 'package:spectre/src/spectre_declarative/element.dart';

/*
<s-material-constant name="sourceR" texture="assetpack://asset.pack.blah" minification="mipmap">
</s-material-constant>
<s-material-constant name="cameraView" data="[]">
</s-material-constant>
<s-material-constant name="blend.source" value="">
</s-material-constant>
<s-material-constant name="depth.func" value="">
</s-material-constant-uniform>
*/

class SpectreMaterialConstantElement extends SpectreElement {
  String name;

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
  }

  removed() {
    super.removed();
  }

  void apply() {
  }


}
