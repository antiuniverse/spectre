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
import 'package:vector_math/vector_math.dart';
import 'package:spectre/spectre_declarative.dart';
import 'spectre_element.dart';

/**
 * <s-transform id="transform"></s-transform>
 *
 * Attributes:
 *
 * * translate (Vector3)
 * * axis (Vector3)
 * * angle (double, radians)
 */
@CustomTag('s-transform')
class SpectreTransformElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {
    'translate': () => new SpectreElementAttributeVector3('translate',
                                                          new Vector3.zero()),
    'axis': () => new SpectreElementAttributeVector3('axis',
                                                     new Vector3(1.0, 0.0,
                                                                 0.0)),
    'angle': () => new SpectreElementAttributeDouble('angle', 0.0)
  };
  final List<String> requiredSpectreAttributes = ['translate', 'axis', 'angle'];
  final Matrix4 T = new Matrix4.zero();
  final Vector3 _v = new Vector3.zero();
  double _d = 0.0;

  created() {
    super.created();
  }

  inserted() {
    super.inserted();
    init();
  }

  removed() {
    super.removed();
  }

  void init() {
    if (inited) {
      // Already initialized.
      return;
    }
    if (!declarativeInstance.inited) {
      // Not ready to initialize.
      return;
    }
    // Initialize.
    super.init();
    _update();
  }

  render() {
    super.render();
    var spectre = declarativeInstance.root;
    spectre.pushTransform(T);
    renderChildren();
    spectre.popTransform();
  }

  void _update() {
    T.setIdentity();
    T.rotate(spectreAttributes['axis'].value, spectreAttributes['angle'].value);
    T.translate(spectreAttributes['translate'].value);
  }
}
