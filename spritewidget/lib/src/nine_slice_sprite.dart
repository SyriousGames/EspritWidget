// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show Image;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'node.dart';
import 'sprite.dart';

/// A NineSliceSprite is similar to a [Sprite], but it it can stretch its
/// inner area to fit the size of the [Node]. This is ideal for fast drawing
/// of things like buttons. Like Android 9-patch, but the image does not contain any special information.
class NineSliceSprite extends Node with SpritePaint {
  ui.Image image;
  Rect centerRect;
  Paint _cachedPaint = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  /// Creates a new NineSliceSprite from the provided [image], [size], and
  /// texture [centerRect].
  NineSliceSprite(this.image, {size, required this.centerRect}) {
    this.size = size;
  }

  @override
  void paint(Canvas canvas) {
    // Setup paint object for opacity and transfer mode.
    updatePaint(_cachedPaint);

    canvas.drawImageNine(image, centerRect,
        Rect.fromLTWH(0, 0, size.width, size.height), _cachedPaint);
  }
}
