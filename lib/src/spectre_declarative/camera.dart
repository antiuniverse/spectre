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

library spectre_declarative_camera;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative_main.dart';
import 'package:spectre/spectre_element.dart';
import 'package:vector_math/vector_math.dart';

/**
 * <s-camera id="mainCamera"></s-camera>
 */
class SpectreCameraElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {
    'field-of-view-y': () =>
        new SpectreElementAttributeDouble('field-of-view-y', 0.785398163),
    'position': () =>
        new SpectreElementAttributeVector3('position',
                                           new Vector3(1.0, 1.0, 1.0)),
    'up-direction': () =>
        new SpectreElementAttributeVector3('up-direction',
                                           new Vector3(0.0, 1.0, 0.0)),
    'view-direction': () =>
        new SpectreElementAttributeVector3('view-direction',
                                           new Vector3(-0.33333, -0.33333,
                                                       -0.33333)),
    'z-near': () => new SpectreElementAttributeDouble('z-near', 0.5),
    'z-far': () => new SpectreElementAttributeDouble('z-far', 1000.0),
  };
  final List<String> requiredSpectreAttributes = [ 'fieldOfViewY',
                                                   'position',
                                                   'upDirection',
                                                   'viewDirection',
                                                   'zNear',
                                                   'zFar'];
  final Camera camera = new Camera();

  void created() {
    super.created();
  }

  void inserted() {
    super.inserted();
    init();
  }

  void removed() {
    super.removed();
  }

  void init() {
    if (inited) {
      // Already initialized.
      return;
    }
    if (!SpectreDeclarative.inited) {
      // Not ready to initialize.
      return;
    }
    // Initialize.
    super.init();
    applyAttributes();
  }

  void applyAttributes() {
    camera.FOV = spectreAttributes['field-of-view-y'].value;
    camera.upDirection.setFrom(spectreAttributes['up-direction'].value);
    camera.position.setFrom(spectreAttributes['position'].value);
    camera.focusPosition.setFrom(camera.position);
    camera.focusPosition.add(spectreAttributes['view-direction'].value);
    camera.zNear = spectreAttributes['z-near'].value;
    camera.zFar = spectreAttributes['z-far'].value;
  }

  void render() {
    super.render();
  }
}
