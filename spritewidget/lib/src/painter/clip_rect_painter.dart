import 'dart:ui';

import '../../spritewidget.dart';

/// Draws clips the child painter using a rectangle.
class ClipRectPainter implements Painter {
  Rect rect;
  Painter childPainter;

  ClipRectPainter(this.rect, this.childPainter);

  @override
  void paint(Canvas canvas, Paint paint) {
    canvas.save();
    canvas.clipRect(rect, doAntiAlias: false);
    childPainter.paint(canvas, paint);
    canvas.restore();
  }

  @override
  Size get size => childPainter.size;
}
