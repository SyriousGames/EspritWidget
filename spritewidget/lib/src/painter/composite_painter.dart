import 'dart:math';
import 'dart:ui';

import '../../spritewidget.dart';

/// Paints the given painters.
class CompositePainter implements Painter {
  final List<Painter> painters;
  late Size _size;
  Size get size => _size;

  CompositePainter(this.painters) {
    var maxWidth = 0.0;
    var maxHeight = 0.0;
    painters.forEach((painter) {
      final painterSize = painter.size;
      maxWidth = max(maxWidth, painterSize.width);
      maxHeight = max(maxHeight, painterSize.height);
    });
    _size = Size(maxWidth, maxHeight);
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    painters.forEach((painter) => painter.paint(canvas, paint));
  }
}
