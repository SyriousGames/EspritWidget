import 'dart:ui';

import '../../spritewidget.dart';

/// Draws a simple horizontal line.
class LinePainter implements Painter {
  final double length;

  // TODO Should really have x1,y1; x2,y2
  LinePainter(this.length);

  @override
  void paint(Canvas canvas, Paint paint) {
    canvas.drawLine(Offset.zero, Offset(length, 0), paint);
  }

  @override
  Size get size => Size(length, 1);
}
