// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'node.dart';
import 'sprite.dart';

/// A [Node] that provides an intermediate rendering surface in the sprite
/// rendering tree. A [Layer] can be used to change the opacity, color, or to
/// apply an effect to a set of nodes. All nodes that are children to the
/// [Layer] will be rendered into the surface. If the area that is needed for
/// the children to be drawn is know, the [layerRect] property should be set as
/// this can enhance performance.
class Layer extends Node with SpritePaint {
  /// The area that the children of the [Layer] will occupy. This value is
  /// treated as a hint to the rendering system and may in some cases be
  /// ignored. If the area isn't known, the layerRect can be set to [null].
  ///
  ///     myLayer.layerRect =  Rect.fromLTRB(0.0, 0.0, 200.0, 100.0);
  Rect? layerRect;

  /// Creates a new layer. The layerRect can optionally be passed as an argument
  /// if it is known.
  ///
  ///     var myLayer =  Layer();
  Layer({this.layerRect, Size size = Size.zero}) : super(size);

  Paint _cachedPaint = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  @override
  void prePaint(Canvas canvas) {
    super.prePaint(canvas);

    // Only perform saveLayer() if we have something set in for the paint.
    if (opacity != 1.0 || colorOverlay != null || transferMode != null) {
      updatePaint(_cachedPaint);
      canvas.saveLayer(layerRect, _cachedPaint);
    }
  }

  @override
  void postPaint(Canvas canvas) {
    // Only restore from saveLayer() if we have something set in for the paint.
    if (opacity != 1.0 || colorOverlay != null || transferMode != null) {
      canvas.restore();
    }

    super.postPaint(canvas);
  }
}
