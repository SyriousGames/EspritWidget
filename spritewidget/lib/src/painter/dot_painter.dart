import 'dart:ui';

import '../../spritewidget.dart';

/// Draws a "dot".
///
/// This may be a single pixel, or if a diameter > 1 is given, a solid circle is drawn.
class DotPainter implements Painter {
  static const List<Offset> point = const [Offset.zero];

  double diameter;

  DotPainter([this.diameter = 1]);

  @override
  void paint(Canvas canvas, Paint paint) {
    final strokeCap = paint.strokeCap;
    final strokeWidth = paint.strokeWidth;
    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = diameter;
    canvas.drawPoints(PointMode.points, point, paint);
    paint.strokeCap = strokeCap;
    paint.strokeWidth = strokeWidth;
  }

  @override
  Size get size => Size(diameter, diameter);
}
