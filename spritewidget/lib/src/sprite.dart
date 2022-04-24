// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show Image;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'node.dart';
import 'painter/painter.dart';
import 'sprite_texture.dart';

/// A Sprite is a [Node] that renders a bitmap image to the screen.
class Sprite extends Node with SpritePaint {
  static const centerOffset = const Offset(0.5, 0.5);

  /// The painter that the sprite will use to render to the screen.
  ///
  /// If the painter is null, the sprite will be rendered as a red square
  /// marking the bounds of the sprite.
  Painter? painter;

  /// If true, constrains the proportions of the image by scaling it down, if its proportions doesn't match the [size].
  ///
  ///     mySprite.constrainProportions = true;
  bool constrainProportions = false;

  Paint _cachedPaint = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  /// Creates a new sprite from the provided [texture].
  ///
  ///     var mySprite =  Sprite(myTexture)
  Sprite([SpriteTexture? texture]) : painter = texture {
    if (texture != null) {
      size = texture.size;
      relativePositionAnchor = texture.pivot;
      scalePivot = texture.pivot;
      rotationPivot = texture.pivot;
    }
  }

  /// The texture that the sprite will render to screen.
  ///
  /// If the texture is null, the sprite will be rendered as a red square
  /// marking the bounds of the sprite.
  set texture(SpriteTexture? texture) => this.painter = texture;

  SpriteTexture? get texture =>
      this.painter is SpriteTexture ? this.painter as SpriteTexture? : null;

  /// Creates a new sprite from the provided [image].
  ///
  /// var mySprite =  Sprite.fromImage(myImage);
  Sprite.fromImage(ui.Image image) : super(Size.zero) {
    painter = SpriteTexture(image);
    size = painter!.size;
  }

  Sprite.fromPainter(this.painter) {
    size = painter!.size;
  }

  @override
  void paint(Canvas canvas) {
    if (painter != null) {
      var w = painter!.size.width;
      var h = painter!.size.height;

      if (w <= 0 || h <= 0) return;

      var scaleX = size.width / w;
      var scaleY = size.height / h;

      if (constrainProportions) {
        // Constrain proportions, using the smallest scale and by centering the image
        if (scaleX < scaleY) {
          canvas.translate(0.0, (size.height - scaleX * h) / 2.0);
          scaleY = scaleX;
        } else {
          canvas.translate((size.width - scaleY * w) / 2.0, 0.0);
          scaleX = scaleY;
        }
      }

      canvas.scale(scaleX, scaleY);

      // Setup paint object for opacity and transfer mode
      updatePaint(_cachedPaint);

      // Do actual drawing of the sprite
      painter!.paint(canvas, _cachedPaint);

      // Debug drawing
      // canvas.drawRect(Offset.zero & painter.size,  Paint()..color=const Color(0x33ff0000));
    } else {
      // Paint a red square for missing painter
      canvas.drawRect(Rect.fromLTRB(0.0, 0.0, size.width, size.height),
          Paint()..color = Color.fromARGB(255, 255, 0, 0));
    }
  }
}

/// Defines properties, such as [opacity] and [transferMode] that are shared
/// between [Node]s that render textures to screen.
abstract class SpritePaint {
  double _opacity = 1.0;

  /// The opacity of the sprite in the range 0.0 to 1.0.
  ///
  ///     mySprite.opacity = 0.5;
  double get opacity => _opacity;

  set opacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    _opacity = opacity;
  }

  /// The color to draw on top of the sprite, null if no color overlay is used.
  ///
  ///     // Color the sprite red
  ///     mySprite.colorOverlay =  Color(0x77ff0000);
  Color? colorOverlay;

  /// The [ColorFilter] used to draw on top of the sprite, null if no filter is used. This is an
  /// alternative to [colorOverlay] and it takes precedence over it if present.
  ColorFilter? colorFilter;

  /// The transfer mode used when drawing the sprite to screen.
  ///
  ///     // Add the colors of the sprite with the colors of the background
  ///     mySprite.transferMode = TransferMode.plusMode;
  BlendMode? transferMode;

  void updatePaint(Paint paint) {
    paint.color = Color.fromARGB((255.0 * _opacity).toInt(), 255, 255, 255);

    if (colorFilter != null) {
      paint.colorFilter = colorFilter;
    } else if (colorOverlay != null) {
      paint.colorFilter = ColorFilter.mode(colorOverlay!, BlendMode.srcATop);
    } else {
      paint.colorFilter = null;
    }

    if (transferMode != null) {
      paint.blendMode = transferMode!;
    }
  }
}
