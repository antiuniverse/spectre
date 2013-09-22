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

part of spectre_declarative;

class SpectreDeclarative {
  static AssetManager assetManager;
  static GraphicsDevice graphicsDevice;
  static GraphicsContext graphicsContext;
  static DebugDrawManager debugDrawManager;
  static SpectreSpectreElement root;
  static bool _inited = false;
  static bool get inited => _inited;
  static DeclarativeExample example;

  static void _initElement(SpectreElement element) {
    element.init();
    element.children.forEach((e) {
      if (e.xtag is SpectreElement) {
        e = e.xtag;
        _initElement(e);
      }
    });
  }

  static void _init() {
    if (_inited) {
      return;
    }
    _inited = true;
    _initElement(root);
  }

  static bool _isAssetPackUrl(String url) {
    return url.startsWith('assetpack://');
  }

  static String _getAssetPackPath(String url) {
    return url.substring('assetpack://'.length);
  }

  static dynamic getAsset(String url) {
    assert(_inited == true);
    if (url == null) return null;
    if (!_isAssetPackUrl(url)) return null;
    var p = _getAssetPackPath(url);
    var a = assetManager[p];
    return a;
  }

  static SpectreElement getElement(String id) {
    if (id == null) {
      return null;
    }
    var q = document.query(id);
    if (q != null) return q.xtag;
    return null;
  }
}
