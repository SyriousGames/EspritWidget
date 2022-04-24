// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'node.dart';

/// Labels are used to display a string of text in a the node tree. To align
/// the label, the textAlign property of the [TextStyle] can be set.
class Label extends Node {
  /// Creates a new Label with the provided [text] and [textStyle].
  /// If [fitText] is true, [textStyle] is used to create a new TextStyle to
  /// resize the font to fit [layoutWidth]. [layoutWidth] must be greater than zero
  /// if [fitText] is true and [textStyle.fontSize] must be set.
  Label(
    this._text, {
    TextStyle? textStyle,
    TextAlign? textAlign,
    double? layoutWidth,
    int maxLines = 1,
    bool fitText = false,
  })  : _textStyle = textStyle ?? const TextStyle(color: Colors.white),
        _textAlign = textAlign ?? TextAlign.left,
        _maxLines = maxLines,
        _layoutWidth = layoutWidth,
        _fitText = fitText {
    assert(!_fitText ||
        (_layoutWidth != null &&
            _layoutWidth! > 0 &&
            _textStyle.fontSize != null));
    _recalcPainter();
  }

  /// The text being drawn by the label.
  String get text => _text;
  String _text;

  set text(String text) {
    _text = text;
    _recalcPainter();
  }

  bool _fitText = false;

  /// The style to draw the text in.
  TextStyle get textStyle => _textStyle;
  TextStyle _textStyle;

  set textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
    _recalcPainter();
  }

  /// How the text should be aligned horizontally.
  TextAlign get textAlign => _textAlign;
  TextAlign _textAlign;

  set textAlign(TextAlign textAlign) {
    _textAlign = textAlign;
    _recalcPainter();
  }

  /// The width to which the text should be aligned. If null, the text is aligned to its natural width.
  double? get layoutWidth => _layoutWidth;
  double? _layoutWidth;

  set layoutWidth(double? layoutWidth) {
    _layoutWidth = layoutWidth;
    _recalcPainter();
  }

  /// The maximum number of lines which can be used to layout the text.
  int get maxLines => _maxLines;
  int _maxLines;

  set maxLines(int maxLines) {
    _maxLines = maxLines;
    _recalcPainter();
  }

  /// The natual width of the text without regard to alignment or [layoutWidth].
  double get naturalWidth => _painter != null ? _painter!.width : 0.0;

  /// The natural height of the text after layout and taking [maxLines] into consideration.
  double get naturalHeight => _painter != null ? _painter!.height : 0.0;

  TextPainter? _painter;
  late Offset _offset;

  _recalcPainter() {
    if (!_fitText) {
      _painter = _createTextPainter(_textStyle, layoutWidth);
    } else {
      _painter = _createTextPainterToFit();
    }

    final width = _layoutWidth ?? _painter!.width;

    _offset = Offset.zero;
    if (textAlign == TextAlign.center) {
      _offset = Offset((width - _painter!.width) / 2.0, 0.0);
    } else if (textAlign == TextAlign.right) {
      _offset = Offset(width - _painter!.width, 0.0);
    }

    size = Size(layoutWidth ?? _painter!.width, _painter!.height);
  }

  TextPainter _createTextPainter(TextStyle textStyle, [double? layoutWidth]) {
    return TextPainter(
      text: TextSpan(style: textStyle, text: _text),
      textDirection: TextDirection.ltr,
      maxLines: _maxLines,
      strutStyle: StrutStyle.fromTextStyle(textStyle),
      ellipsis: '\u2026',
    )..layout(maxWidth: layoutWidth ?? double.infinity);
  }

  TextPainter _createTextPainterToFit() {
    TextPainter painter = _createTextPainter(_textStyle);
    if (painter.width <= _layoutWidth!) {
      return painter;
    }

    // Binary search for the largest size that still fits.
    var minSize = 1.0;
    var maxSize = _textStyle.fontSize!;
    var fitSize = minSize;
    while (minSize <= maxSize) {
      final mid = (minSize + (maxSize - minSize) / 2).floor().toDouble();
      painter = _createTextPainter(_textStyle.copyWith(fontSize: mid));
      if (painter.width <= _layoutWidth!) {
        // Fits
        fitSize = mid;
        minSize = mid + 1.0;
      } else {
        maxSize = mid - 1.0;
      }
    }

    return _createTextPainter(
        _textStyle.copyWith(fontSize: fitSize), _layoutWidth);
  }

  @override
  void paint(Canvas canvas) {
    _painter!.paint(canvas, _offset);
  }
}
