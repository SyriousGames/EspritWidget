import 'dart:ui';

import '../../spritewidget.dart';

/// Paints the given path.
class PathPainter implements Painter {
  final Path path;
  final Paint? overridePaint;

  PathPainter(this.path, {this.overridePaint});

  Size get size => path.getBounds().size;

  @override
  void paint(Canvas canvas, Paint paint) {
    canvas.drawPath(path, overridePaint ?? paint);
  }
}
