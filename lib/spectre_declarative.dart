/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

library spectre_declarative;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:math' as Math;
import 'dart:async';
import 'dart:typed_data';

import 'package:asset_pack/asset_pack.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:spectre/spectre_example_ui.dart';

import 'package:spectre/src/spectre_declarative/camera.dart';
import 'package:spectre/src/spectre_declarative/element.dart';
import 'package:spectre/src/spectre_declarative/layer.dart';
import 'package:spectre/src/spectre_declarative/line_primitive.dart';
import 'package:spectre/src/spectre_declarative/material.dart';
import 'package:spectre/src/spectre_declarative/material_constant.dart';
import 'package:spectre/src/spectre_declarative/model.dart';
import 'package:spectre/src/spectre_declarative/post_effect.dart';
import 'package:spectre/src/spectre_declarative/scene.dart';
import 'package:spectre/src/spectre_declarative/transform.dart';

export 'package:spectre/src/spectre_declarative/camera.dart';
export 'package:spectre/src/spectre_declarative/layer.dart';
export 'package:spectre/src/spectre_declarative/line_primitive.dart';
export 'package:spectre/src/spectre_declarative/material.dart';
export 'package:spectre/src/spectre_declarative/material_constant.dart';
export 'package:spectre/src/spectre_declarative/model.dart';
export 'package:spectre/src/spectre_declarative/post_effect.dart';
export 'package:spectre/src/spectre_declarative/scene.dart';
export 'package:spectre/src/spectre_declarative/transform.dart';

import 'package:vector_math/vector_math.dart';

part 'src/spectre_declarative/example.dart';
