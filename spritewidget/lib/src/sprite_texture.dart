// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui show Image;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'sprite.dart';
import 'painter/painter.dart';

/// A texture represents a rectangular area of an image and is typically used to draw a sprite to the screen.
///
/// Normally you get a reference to a texture from a [SpriteSheet], but you can also create one from an [Image].
class SpriteTexture implements Painter {
  /// Creates a new texture from an [Image] object.
  ///
  ///     var myTexture = new Texture(myImage);
  SpriteTexture(ui.Image image)
      : size = Size(image.width.toDouble(), image.height.toDouble()),
        image = image,
        trimmed = false,
        rotated = false,
        scale = 1.0,
        frame = Rect.fromLTRB(
            0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        spriteSourceSize = Rect.fromLTRB(
            0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        pivot = Sprite.centerOffset {
    fixedFrame = frame;
    fixedSpriteSourceSize = spriteSourceSize;
  }

  SpriteTexture.fromSpriteFrame(this.image, this.name, this.size, this.rotated,
      this.trimmed, this.frame, this.spriteSourceSize, this.pivot, this.scale) {
    if (rotated) {
      // NOTE!!! For frame and spriteSourceSize, the width and height haven't been swapped if the texture
      // has been rotated. With both TexturePacker and free-tex-packer.
      fixedFrame =
          Rect.fromLTWH(frame.left, frame.top, frame.height, frame.width);
      fixedSpriteSourceSize = Rect.fromLTWH(
          spriteSourceSize.left,
          spriteSourceSize.top,
          spriteSourceSize.height,
          spriteSourceSize.width);
    } else {
      fixedFrame = frame;
      fixedSpriteSourceSize = spriteSourceSize;
    }
  }

  /// The image that this texture is a part of.
  ///
  ///     var textureImage = myTexture.image;
  final ui.Image image;

  /// The logical size of the texture, before being trimmed by the texture packer.
  ///
  ///     var textureSize = myTexture.size;
  final Size size;

  /// The name of the image acts as a tag when acquiring a reference to it.
  ///
  ///     myTexture.name = "new_texture_name";
  String? name;

  /// True if the texture was rotated 90 degrees when being packed into a sprite sheet.
  ///
  ///     if (myTexture.rotated) drawRotated();
  final bool rotated;

  /// Scaling of the texture.
  ///
  /// E.g., if 0.5, it means that it must be scaled by (1 / 0.5) = 2 to render it at the expected size.
  final double scale;

  /// The texture was trimmed when being packed into a sprite sheet.
  ///
  ///     bool trimmed = myTexture.trimmed
  final bool? trimmed;

  /// The frame of the trimmed texture inside the image.
  ///
  ///     Rect frame = myTexture.frame;
  final Rect frame;

  /// The frame of the trimmed texture inside the image with width and height corrected (swapped) if [rotated] is true.
  Rect? fixedFrame;

  /// The offset and size of the trimmed texture inside the image.
  ///
  /// Position represents the offset from the logical [size], the size of the rect represents the size of the trimmed
  /// texture.
  ///
  ///     Rect spriteSourceSize = myTexture.spriteSourceSize;
  final Rect spriteSourceSize;

  /// The spriteSourceSize of the trimmed texture inside the image with width and height corrected (swapped) if [rotated] is true.
  Rect? fixedSpriteSourceSize;

  /// The default pivot point for this texture. When creating a [Sprite] from the texture, this is the pivot point that
  /// will be used.
  ///
  ///     myTexture.pivot = new Point(0.5, 0.5);
  Offset pivot;

  /// Creates a new Texture from a part of the current texture.
  SpriteTexture textureFromRect(Rect rect, [String? name]) {
    assert(rect != null);
    assert(!rotated);
    Rect srcFrame = Rect.fromLTWH(rect.left + frame.left, rect.top + frame.top,
        rect.size.width, rect.size.height);
    Rect dstFrame = Rect.fromLTWH(0.0, 0.0, rect.size.width, rect.size.height);
    return SpriteTexture.fromSpriteFrame(image, name, rect.size, false, false,
        srcFrame, dstFrame, Offset(0.5, 0.5), scale);
  }

  /// Paints the texture to a [Canvas] with the specified [paint].
  void paint(Canvas canvas, Paint paint) {
    // TODO Needs work to support trimmed textures, and texture atlas scaling.
    // Draw the texture
    if (rotated) {
      // Calculate the rotated frame and spriteSourceSize
      Size originalFrameSize = frame.size;
      Rect rotatedFrame = frame.topLeft &
          Size(originalFrameSize.height, originalFrameSize.width);
      Offset rotatedSpriteSourcePoint = Offset(
          -spriteSourceSize.top -
              (spriteSourceSize.bottom - spriteSourceSize.top),
          spriteSourceSize.left);
      Rect rotatedSpriteSourceSize = rotatedSpriteSourcePoint &
          Size(originalFrameSize.height, originalFrameSize.width);

      // Draw the rotated sprite
      canvas.rotate(-math.pi / 2.0);
      canvas.drawImageRect(image, rotatedFrame, rotatedSpriteSourceSize, paint);
      canvas.rotate(math.pi / 2.0);
    } else {
      // Draw the sprite
      canvas.drawImageRect(image, frame, spriteSourceSize, paint);
    }
  }
}
