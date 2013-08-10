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
class SpectreTextureElement extends SpectreElement {
  final Map<String, AttributeConstructor> spectreAttributeDefinitions = {
    'src': () => new SpectreElementAttributeString('src',''),
    'type': () => new SpectreElementAttributeString('type', 'auto'),
    'format': () => new SpectreElementAttributeString('format',
                                                      'PixelFormat.Rgba'),
    'datatype': () => new SpectreElementAttributeString('datatype',
                                                        'DataType.Uint8'),
    'color': () => new SpectreElementAttributeString('color', ''),
    'width': () => new SpectreElementAttributeInt('width', 0),
    'height': () => new SpectreElementAttributeInt('height', 0),
  };
  final List<String> requiredSpectreAttributes = [ 'src',
                                                   'type',
                                                   'format',
                                                   'datatype',
                                                   'storage',
                                                   'color',
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

  String _detectType(String uri) {
    String extension = path.extension(uri);
    if ((extension == '.jpg') || (extension == '.png') ||
        (extension == '.gif')) {
      return '2d';
    }
    if ((extension == 'texCube')) {
      return 'cube';
    }
    return 'color';
  }

  void _destroyOldTexture() {
    if (_texture != null) {
      _texture.dispose();
      _texture = null;
    }
  }

  void _parseColorIntoColorBuffer(Uint8List colorBuffer) {
    colorBuffer[0] = 0x77;
    colorBuffer[1] = 0x77;
    colorBuffer[2] = 0x77;
    colorBuffer[3] = 0xFF;
    String color = spectreAttributes['color'].value;
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

  void _createColorTexture() {
    _destroyOldTexture();
    Uint8List colorBuffer = new Uint8List(4);
    _parseColorIntoColorBuffer(colorBuffer);
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
      type = _detectType(_src);
    }
    if (type == '2d') {
      _texture = new Texture2D('SpectreTextureElement',
                               SpectreDeclarative.graphicsDevice);
    } else if (type == 'cube') {
      _texture = new TextureCube('SpectreTextureElement',
                                 SpectreDeclarative.graphicsDevice);
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

  void _loadTexture() {
    if (_texture == null || _src == '') {
      return;
    }
    if (_texture is Texture2D) {
      (_texture as Texture2D).uploadFromURL(_src.toString());
    } else if (_texture is TextureCube) {
      throw new FallThroughError();
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
