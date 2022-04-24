import 'dart:ui';

import '../../spritewidget.dart';

/// Draws a simple rectangle.
class RectPainter implements Painter {
  final Size size;

  RectPainter(this.size);

  @override
  void paint(Canvas canvas, Paint paint) {
    canvas.drawRect(Offset.zero & size, paint);
  }
}
