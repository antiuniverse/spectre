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

library spectre_declarative_transform;

import 'package:polymer/polymer.dart';
import 'package:spectre/src/spectre_declarative/element.dart';
import 'package:vector_math/vector_math.dart';

/**
 * <s-camera id="mainCamera"></s-camera>
 *
 * Attributes:
 *
 * * translate (Vector3)
 * * axis (Vector3)
 * * angle (double, radians)
 */

class SpectreTransformElement extends SpectreElement {
  final Matrix4 T = new Matrix4.zero();
  final Vector3 _v = new Vector3.zero();
  double _d = 0.0;

  void _update() {
    T.setIdentity();
    if (!parseVector3('axis', _v)) {
      _v[0] = 1.0;
      _v[1] = 0.0;
      _v[2] = 0.0;
    }
    _d = parseDouble('angle', 0.0);
    T.rotate(_v, _d);
    if (!parseVector3('translate', _v)) {
      _v[0] = 0.0;
      _v[1] = 0.0;
      _v[2] = 0.0;
    }
    T.translate(_v);
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
  }
}
