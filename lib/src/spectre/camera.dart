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

part of spectre;

class Camera {
  Vector3 position;
  Vector3 upDirection;
  Vector3 focusPosition;
  bool orthographic = false;
  double zNear = 0.5;
  double zFar = 1000.0;
  double aspectRatio = 1.7777778;
  double FOV = 0.785398163;
  double orthographicSize = 1.0;

  String toString() {
    return '$position -> $focusPosition';
  }

  Camera() {
    position = new Vector3(0.0, 0.0, 0.0);
    focusPosition = new Vector3(0.0, 0.0, -1.0);
    upDirection = new Vector3(0.0, 1.0, 0.0);
  }

  num get yaw {
    Vector3 z = new Vector3(0.0, 0.0, 1.0);
    Vector3 forward = frontDirection;
    forward.normalize();
    num d = degrees(Math.acos(forward.dot(z)));
    return d;
  }

  num get pitch {
    Vector3 y = new Vector3(0.0, 1.0, 0.0);
    Vector3 forward = frontDirection;
    forward.normalize();
    num d = degrees(Math.acos(forward.dot(y)));
    return d;
  }

  Matrix4 get projectionMatrix {
    if (orthographic == false) {
      return makePerspectiveMatrix(FOV, aspectRatio, zNear, zFar);
    } else {
      double orthoHalfHeight = orthographicSize;
      double orthoHalfWidth = orthographicSize * aspectRatio;
      return makeOrthographicMatrix(-orthoHalfWidth, orthoHalfWidth, -orthoHalfHeight, orthoHalfHeight, zNear, zFar);
    }
  }

  Matrix4 get viewMatrix {
    return makeViewMatrix(position, focusPosition, upDirection);
  }

  void copyProjectionMatrixIntoArray(Float32List pm) {
    Matrix4 m;

    if (orthographic == false) {
      m = makePerspectiveMatrix(FOV, aspectRatio, zNear, zFar);
    } else {
      double orthoHalfHeight = orthographicSize;
      double orthoHalfWidth = orthographicSize * aspectRatio;
      m = makeOrthographicMatrix(-orthoHalfWidth, orthoHalfWidth, -orthoHalfHeight, orthoHalfHeight, zNear, zFar);
    }

    m.copyIntoArray(pm);
  }

  void copyViewMatrixIntoArray(Float32List vm) {
    Matrix4 m = makeViewMatrix(position, focusPosition, upDirection);
    m.copyIntoArray(vm);
  }

  void copyNormalMatrixIntoArray(Float32List nm) {
    Matrix4 m = makeViewMatrix(position, focusPosition, upDirection);
    m.copyIntoArray(nm);
  }

  void copyProjectionMatrix(Matrix4 pm) {
    if (orthographic == false) {
      setPerspectiveMatrix(pm, FOV, aspectRatio, zNear, zFar);
    } else {
      double orthoHalfHeight = orthographicSize;
      double orthoHalfWidth = orthographicSize * aspectRatio;
      setOrthographicMatrix(pm, -orthoHalfWidth, orthoHalfWidth, -orthoHalfHeight, orthoHalfHeight, zNear, zFar);
    }
  }

  void copyViewMatrix(Matrix4 vm) {
    setViewMatrix(vm, position, focusPosition, upDirection);
  }

  void copyNormalMatrix(Matrix4 nm) {
    setViewMatrix(nm, position, focusPosition, upDirection);
  }

  void copyEyePosition(Vector3 ep) {
    position.copyInto(ep);
  }

  void copyLookAtPosition(Vector3 lap) {
    focusPosition.copyInto(lap);
  }

  Vector3 get frontDirection => (focusPosition-position).normalize();
}
