import 'dart:ui';

/// Something that can paint itself to a canvas.
abstract class Painter {
  /// The size of the bounding box.
  ///
  /// Can be used, for example, to scale to the desired size before painting.
  Size get size;

  /// Paint to [canvas], optionally using paint to modulate the result.
  void paint(Canvas canvas, Paint paint);
}
