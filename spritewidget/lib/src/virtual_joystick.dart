// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'motion.dart';
import 'node.dart';
import 'sprite_box.dart';

/// Provides a virtual joystick that can easily be added to your sprite scene.
class VirtualJoystick extends Node {
  /// Creates a new virtual joystick.
  VirtualJoystick() : super(Size(160.0, 160.0)) {
    userInteractionEnabled = true;
    handleMultiplePointers = false;
    position = Offset(160.0, -20.0);
    relativePositionAnchor = Offset(0.5, 1.0);
    _center = Offset(size.width / 2.0, size.height / 2.0);
    _handlePos = _center;

    _paintHandle = Paint()..color = Color(0xffffffff);
    _paintControl = Paint()
      ..color = Color(0xffffffff)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
  }

  /// Reads the current value of the joystick. A point with from (-1.0, -1.0)
  /// to (1.0, 1.0). If the joystick isn't moved it will return (0.0, 0.0).
  Offset get value => _value;
  Offset _value = Offset.zero;

  /// True if the user is currently touching the joystick.
  bool get isDown => _isDown;
  bool _isDown = false;

  Offset _pointerDownAt = Offset.zero;
  late Offset _center;
  late Offset _handlePos;

  late Paint _paintHandle;
  late Paint _paintControl;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type is PointerDownEvent) {
      _pointerDownAt = event.boxPosition;
      motions.stopAll();
      _isDown = true;
    } else if (event.type is PointerUpEvent ||
        event.type is PointerCancelEvent) {
      _pointerDownAt = Offset.zero;
      _value = Offset.zero;
      MotionTween moveToCenter = MotionTween((a) {
        _handlePos = a;
      }, _handlePos, _center, 0.4, Curves.elasticOut);
      motions.run(moveToCenter);
      _isDown = false;
    } else if (event.type is PointerMoveEvent) {
      Offset movedDist = event.boxPosition - _pointerDownAt;

      _value = Offset((movedDist.dx / 80.0).clamp(-1.0, 1.0),
          (movedDist.dy / 80.0).clamp(-1.0, 1.0));

      _handlePos = _center + Offset(_value.dx * 40.0, _value.dy * 40.0);
    }
    return true;
  }

  @override
  void paint(Canvas canvas) {
    canvas.drawCircle(_handlePos, 25.0, _paintHandle);
    canvas.drawCircle(_center, 40.0, _paintControl);
  }
}
