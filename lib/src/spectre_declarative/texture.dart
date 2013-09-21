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

library spectre_declarative_texture;

import 'dart:async';
import 'dart:typed_data';
import 'package:pathos/path.dart' as path;
import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_element.dart';
import 'package:spectre/spectre_declarative_main.dart';
import 'package:vector_math/vector_math.dart';

/**
 * <s-texture id="textureId"></s-texture>
 *
 * Attributes:
 *
 * * src String
 * * type String ('auto', '2d', 'cube', 'color')
 * * format String (see pixel_format.dart)
 * * datatype String (see data_type.dart)
 * * color String (4 component hex string #rrggbbaa)
 * * width String (width of mip level 0)
 * * height String (height of mip level 0)
 */
@CustomTag('s-texture')
class SpectreTextureElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {
    'src': () => new SpectreElementAttributeString('src',''),
    'src-cube-negative-x':
        () => new SpectreElementAttributeString('src-cube-negative-x', null),
    'src-cube-negative-y':
        () => new SpectreElementAttributeString('src-cube-negative-y', null),
    'src-cube-negative-z':
        () => new SpectreElementAttributeString('src-cube-negative-z', null),
    'src-cube-positive-x':
        () => new SpectreElementAttributeString('src-cube-positive-x', null),
    'src-cube-positive-y':
        () => new SpectreElementAttributeString('src-cube-positive-y', null),
    'src-cube-positive-z':
        () => new SpectreElementAttributeString('src-cube-positive-z', null),
    'type': () => new SpectreElementAttributeString('type', 'auto'),
    'format': () => new SpectreElementAttributeString('format',
                                                      'PixelFormat.Rgba'),
    'datatype': () => new SpectreElementAttributeString('datatype',
                                                        'DataType.Uint8'),
    'color': () => new SpectreElementAttributeString('color', ''),
    'color-cube-negative-x':
        () => new SpectreElementAttributeString('color-cube-negative-x', null),
    'color-cube-negative-y':
        () => new SpectreElementAttributeString('color-cube-negative-y', null),
    'color-cube-negative-z':
        () => new SpectreElementAttributeString('color-cube-negative-z', null),
    'color-cube-positive-x':
        () => new SpectreElementAttributeString('color-cube-positive-x', null),
    'color-cube-positive-y':
        () => new SpectreElementAttributeString('color-cube-positive-y', null),
    'color-cube-positive-z':
        () => new SpectreElementAttributeString('color-cube-positive-z', null),
    'width': () => new SpectreElementAttributeInt('width', 0),
    'height': () => new SpectreElementAttributeInt('height', 0),
  };
  final List<String> requiredSpectreAttributes = [ 'src',
                                                   'src-cube-positive-x',
                                                   'src-cube-positive-y',
                                                   'src-cube-positive-z',
                                                   'src-cube-negative-x',
                                                   'src-cube-negative-y',
                                                   'src-cube-negative-z',
                                                   'type',
                                                   'format',
                                                   'datatype',
                                                   'storage',
                                                   'color',
                                                   'color-cube-positive-x',
                                                   'color-cube-positive-y',
                                                   'color-cube-positive-z',
                                                   'color-cube-negative-x',
                                                   'color-cube-negative-y',
                                                   'color-cube-negative-z',
                                                   'width',
                                                   'height' ];
  SpectreTexture _texture;
  SpectreTexture get texture => _texture;
  String _src;
  int _pixelFormat;
  int _dataType;
  int _width;
  int _height;

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
    if (!SpectreDeclarative.inited) {
      // Not ready to initialize.
      return;
    }
    // Initialize.
    super.init();
    _update();
    _applyAttributes();
  }


  bool _hasCubeAttributes() {
    return (spectreAttributes['color-cube-negative-x'].value != null) ||
           (spectreAttributes['color-cube-negative-y'].value != null) ||
           (spectreAttributes['color-cube-negative-z'].value != null) ||
           (spectreAttributes['color-cube-positive-x'].value != null) ||
           (spectreAttributes['color-cube-positive-y'].value != null) ||
           (spectreAttributes['color-cube-positive-z'].value != null) ||
           (spectreAttributes['src-cube-negative-x'].value != null) ||
           (spectreAttributes['src-cube-negative-y'].value != null) ||
           (spectreAttributes['src-cube-negative-z'].value != null) ||
           (spectreAttributes['src-cube-positive-x'].value != null) ||
           (spectreAttributes['src-cube-positive-y'].value != null) ||
           (spectreAttributes['src-cube-positive-z'].value != null);
  }

  String _detectType() {
    String extension = path.extension(_src);
    if ((extension == '.texCube') || _hasCubeAttributes()) {
      return 'cube';
    }
    if ((extension == '.jpg') || (extension == '.png') ||
        (extension == '.gif')) {
      return '2d';
    }
    return 'color';
  }

  void _destroyOldTexture() {
    if (_texture != null) {
      _texture.dispose();
      _texture = null;
    }
  }

  void _parseColorIntoColorBuffer(String color, Uint8List colorBuffer) {
    colorBuffer[0] = 0x77;
    colorBuffer[1] = 0x77;
    colorBuffer[2] = 0x77;
    colorBuffer[3] = 0xFF;
    if (color.length != 9 || color[0] != '#') {
      return;
    }
    try {
      String r = color.substring(1, 3);
      String g = color.substring(3, 5);
      String b = color.substring(5, 7);
      String a = color.substring(7, 9);
      colorBuffer[0] = int.parse(r, radix:16) & 0xFF;
      colorBuffer[1] = int.parse(g, radix:16) & 0xFF;
      colorBuffer[2] = int.parse(b, radix:16) & 0xFF;
      colorBuffer[3] = int.parse(a, radix:16) & 0xFF;
    } catch (e) {
    }
  }

  static final Uint8List _patternColorBuffer = new Uint8List.fromList(
      [0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff]);

  void _uploadDefaultColorPattern(Texture2D texture) {
    texture.uploadPixelArray(4, 4, _patternColorBuffer);
  }

  void _createColorTexture() {
    _destroyOldTexture();
    Uint8List colorBuffer = new Uint8List(4);
    _parseColorIntoColorBuffer(spectreAttributes['color'].value, colorBuffer);
    // Create new texture.
    var t = new Texture2D('SpectreTextureElement',
                          SpectreDeclarative.graphicsDevice);
    // Upload a 1x1 pixel texture.
    t.uploadPixelArray(1, 1, colorBuffer);
    // Generate mip maps.
    t.generateMipmap();
    _texture = t;
  }

  void _createTexture() {
    _destroyOldTexture();
    String type = spectreAttributes['type'].value;
    if (type == 'auto') {
      type = _detectType();
    }
    if (type == '2d') {
      var t = new Texture2D('SpectreTextureElement',
                            SpectreDeclarative.graphicsDevice);
      _uploadDefaultColorPattern(t);
      t.generateMipmap();
      _texture = t;
    } else if (type == 'cube') {
      var t = new TextureCube('SpectreTextureElement',
                              SpectreDeclarative.graphicsDevice);
      _uploadDefaultColorPattern(t.positiveX);
      _uploadDefaultColorPattern(t.positiveY);
      _uploadDefaultColorPattern(t.positiveZ);
      _uploadDefaultColorPattern(t.negativeX);
      _uploadDefaultColorPattern(t.negativeY);
      _uploadDefaultColorPattern(t.negativeZ);
      t.generateMipmap();
      _texture = t;
    } else if (type == 'color') {
      _createColorTexture();
    } else {
      throw new FallThroughError();
    }
  }

  void _applyAttributes() {
    _pixelFormat = PixelFormat.parse(spectreAttributes['format'].value);
    _dataType = DataType.parse(spectreAttributes['datatype'].value);
    _src = spectreAttributes['src'].value;
    _width = spectreAttributes['width'].value;
    _height = spectreAttributes['height'].value;
    _createTexture();
    _loadTexture();
  }

  Future _loadCubeTexture(Texture2D texture2D, String face) {
    String src = spectreAttributes['src-$face'].value;
    if (src == null) {
      src = spectreAttributes['src'].value;
    }
    String color = spectreAttributes['color-$face'].value;
    if (color == null) {
      color = spectreAttributes['color'].value;
    }
    if (src != '') {
      // Upload from source.
      print('upload $src');
      return texture2D.uploadFromURL(src);
    } else {
      // Parse color.
      Uint8List colorBuffer = new Uint8List(4);
      _parseColorIntoColorBuffer(color, colorBuffer);
      // Upload a 1x1 pixel texture.
      texture2D.uploadPixelArray(1, 1, colorBuffer);
    }
    return new Future.value(texture2D);
  }

  void _loadTexture() {
    if (_texture == null) {
      return;
    }
    if (_texture is Texture2D) {
      if (_src == '') {
        return;
      }
      (_texture as Texture2D).uploadFromURL(_src.toString()).then((t) {
        t.generateMipmap();
      });
    } else if (_texture is TextureCube) {
      var t = _texture;
      List l = [];
      l.add(_loadCubeTexture(t.positiveX, 'cube-positive-x'));
      l.add(_loadCubeTexture(t.positiveY, 'cube-positive-y'));
      l.add(_loadCubeTexture(t.positiveZ, 'cube-positive-z'));
      l.add(_loadCubeTexture(t.negativeX, 'cube-negative-x'));
      l.add(_loadCubeTexture(t.negativeY, 'cube-negative-y'));
      l.add(_loadCubeTexture(t.negativeZ, 'cube-negative-z'));
      Future.wait(l).then((_) {
        t.generateMipmap();
      });
    } else {
      throw new FallThroughError();
    }
  }

  render() {
    super.render();
  }

  void _update() {
  }
}
