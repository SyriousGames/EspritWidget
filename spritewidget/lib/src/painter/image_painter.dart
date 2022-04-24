import 'dart:ui';

import '../picture_to_image_renderer.dart';
import 'painter.dart';

class ImagePainter implements Painter {
  /// Paints an image.
  ///
  /// If [size] is specified, the image is scaled to this size, otherwise will be drawn at its natural size.
  /// Either the width OR height of [size] may be zero, in which case the
  /// picture is scaled with regard to the aspect ratio and the opposite dimension.
  ImagePainter(this._image, {Size? size}) {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    var scaleAndSize = scaleWithOneAspectMissing(imageSize, size);
    _xScale = scaleAndSize.xScale;
    _yScale = scaleAndSize.yScale;
    _size = scaleAndSize.size;
  }

  late Size _size;

  @override
  Size get size => _size;

  late double _xScale, _yScale;

  final Image _image;

  Image get image => _image;

  @override
  void paint(Canvas canvas, Paint paint) {
    final scaled = _xScale != 1 || _yScale != 1;
    if (scaled) {
      canvas.save();
      canvas.scale(_xScale, _yScale);
    }

    canvas.drawImage(image, Offset.zero, paint);

    if (scaled) {
      canvas.restore();
    }
  }
}
