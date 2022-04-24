// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:ui' as ui show Image;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'sprite_texture.dart';

/// A sprite sheet packs a number of smaller images into a single large image.
///
/// The placement of the smaller images are defined by a json file. The larger image and json file is typically created
/// by a tool such as TexturePacker. The [SpriteSheet] class will take a reference to a larger image and a json string.
/// From the image and the string the [SpriteSheet] creates a number of [SpriteTexture] objects. The names of the frames in
/// the sprite sheet definition are used to reference the different textures.
class SpriteSheet {
  ui.Image _image;
  Map<String, SpriteTexture> _textures = Map<String, SpriteTexture>();

  Map<String, SpriteTexture> get textures => _textures;

  /// Creates a new sprite sheet from an [_image] and a sprite sheet [jsonDefinition].
  ///
  ///     var mySpriteSheet =  SpriteSheet(myImage, jsonString);
  SpriteSheet(this._image, String jsonDefinition) {
    JsonDecoder decoder = JsonDecoder();
    Map<String, dynamic> file = decoder.convert(jsonDefinition);

    // Note: This wants "frames" to be an array and not a hash
    final frames = file["frames"];
    final num? scale = file["meta"]["scale"];

    for (Map<String, dynamic> frameInfo in frames) {
      String fileName = frameInfo["filename"] ?? 'unknown';
      Rect frame = _readJsonRect(frameInfo["frame"]);
      bool? rotated = frameInfo["rotated"];
      bool? trimmed = frameInfo["trimmed"];
      Rect spriteSourceSize = _readJsonRect(frameInfo["spriteSourceSize"]);
      Size sourceSize = _readJsonSize(frameInfo["sourceSize"]);
      Offset pivot = _readJsonPoint(frameInfo["pivot"]);

      // NOTE!!! For frame and spriteSourceSize, the width and height haven't been swapped if the texture
      // has been rotated. With both TexturePacker and free-tex-packer.

      SpriteTexture texture = SpriteTexture.fromSpriteFrame(
          _image,
          fileName,
          sourceSize,
          rotated ?? false,
          trimmed,
          frame,
          spriteSourceSize,
          pivot,
          scale!.toDouble());
      _textures[fileName] = texture;
    }
  }

  Rect _readJsonRect(Map<dynamic, dynamic> data) {
    num x = data["x"];
    num y = data["y"];
    num w = data["w"];
    num h = data["h"];

    return Rect.fromLTRB(
        x.toDouble(), y.toDouble(), (x + w).toDouble(), (y + h).toDouble());
  }

  Size _readJsonSize(Map<dynamic, dynamic> data) {
    num w = data["w"];
    num h = data["h"];

    return Size(w.toDouble(), h.toDouble());
  }

  Offset _readJsonPoint(Map<dynamic, dynamic> data) {
    num x = data["x"];
    num y = data["y"];

    return Offset(x.toDouble(), y.toDouble());
  }

  /// The image used by the sprite sheet.
  ///
  ///     var spriteSheetImage = mySpriteSheet.image;
  ui.Image get image => _image;

  /// Returns a texture by its name.
  ///
  ///     var myTexture = mySpriteSheet["example.png"];
  SpriteTexture? operator [](String fileName) => _textures[fileName];
}
