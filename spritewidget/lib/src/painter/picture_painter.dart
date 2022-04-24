import 'dart:ui';

import 'painter.dart';
import '../picture_to_image_renderer.dart';

/// Paints a [Picture].
class PicturePainter implements Painter {
  final Picture picture;
  late Size _desiredSize;
  late double _xScale, _yScale;

  /// Construct a [PicturePainter].
  ///
  /// [pictureSize] is the picture's natural size.
  /// [desiredSize] is the picture's desired size when rendered. If null, it will
  /// be rendered at [pictureSize]. Either the width OR height of [desiredSize] may be zero, in which case the
  /// picture is scaled with regard to the aspect ratio and the opposite dimension.
  PicturePainter(this.picture, Size pictureSize, {Size? desiredSize = null}) {
    var scaleAndSize = scaleWithOneAspectMissing(pictureSize, desiredSize);
    _xScale = scaleAndSize.xScale;
    _yScale = scaleAndSize.yScale;
    _desiredSize = scaleAndSize.size;
  }

  @override
  Size get size => _desiredSize;

  @override
  void paint(Canvas canvas, Paint paint) {
    if (_xScale != 1.0 || _yScale != 1.0) {
      canvas.save();
      canvas.scale(_xScale, _yScale);
      canvas.drawPicture(picture);
      canvas.restore();
    } else {
      canvas.drawPicture(picture);
    }
  }
}
