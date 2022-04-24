import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'painter/image_painter.dart';
import 'painter/painter.dart';
import 'painter/picture_painter.dart';

class PictureWithSize {
  final Picture picture;
  final Size pictureSize;

  PictureWithSize(this.picture, this.pictureSize);
}

/// Create an [Image] from a [picture]. Image is generated asynchronously.
///
/// You must specify [pictureSize] because [Picture] doesn't have an inherent size.
/// [desiredSize] is optional, but if specified, is the number of pixels to which the picture should be scaled.
/// If either one of [desiredSize.width] or
/// [desiredSize.height] is 0 the picture aspect ratio is maintained and is scaled using the opposing dimension.
/// [scale] can be used to scale up the image. This can be used to scale-up the
/// image by ui.window.devicePixelRatio so the image can be drawn scaled-down
/// so it isn't fuzzy after rendering (see https://github.com/flutter/flutter/issues/17782).
/// The resulting image is desiredSize * scale.
Future<Image> pictureToImage(picture, pictureSize,
    {Size? desiredSize, double scale = 1.0}) async {
  assert(picture != null);
  assert(pictureSize != null);
  assert(
      desiredSize == null || desiredSize.width != 0 || desiredSize.height != 0);
  return _generateImage(picture, pictureSize, desiredSize, scale);
}

/// Create a [PictureWithSize] from an SVG asset. SVG is loaded asynchronously.
Future<PictureWithSize> svgToPicture(
    AssetBundle bundle, String svgAssetName) async {
  final svgStr = await bundle.loadString(svgAssetName);
  final drawableRoot = await svg.fromSvgString(svgStr, svgStr);
  final pictureSize = drawableRoot.viewport.viewBox;
  return PictureWithSize(
      drawableRoot.toPicture(size: pictureSize), pictureSize);
}

/// Create a [Painter] from an SVG asset. SVG is loaded asynchronously.
///
/// [desiredSize] is optional, but if specified, is the number of pixels to which the picture should be scaled.
/// If either one of [desiredSize.width] or
/// [desiredSize.height] is 0 the picture aspect ratio is maintained and is scaled using the opposing dimension.
/// If [renderAsImage] is true (default), the SVG will be rendered and painted as an image.
Future<Painter> svgToPainter(AssetBundle bundle, String svgAssetName,
    {Size? desiredSize, bool renderAsImage = true}) async {
  final p = await svgToPicture(bundle, svgAssetName);
  if (renderAsImage) {
    // To get this to render without fuzziness on-screen, you have to render to
    // an image suitable for the device pixels, and then scale it down when painting it.
    // See https://github.com/flutter/flutter/issues/17782
    final image = await pictureToImage(p.picture, p.pictureSize,
        desiredSize: desiredSize! * window.devicePixelRatio);
    return ImagePainter(image, size: desiredSize);
  } else {
    return PicturePainter(p.picture, p.pictureSize, desiredSize: desiredSize);
  }
}

Future<Image> _generateImage(Picture _picture, Size _pictureSize,
    Size? _desiredSize, double scale) async {
  var scaleAndSize = scaleWithOneAspectMissing(_pictureSize, _desiredSize);
  var renderPicture = _picture;
  if (scaleAndSize.xScale != 1.0 || scaleAndSize.yScale != 1.0) {
    // Scale the picture to the desired size
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(scaleAndSize.xScale, scaleAndSize.yScale);
    canvas.drawPicture(_picture);

    renderPicture = recorder.endRecording();
  }

  return renderPicture.toImage(scaleAndSize.size.width.round().toInt(),
      scaleAndSize.size.height.round().toInt());
}

/// [originalSize] is the original size.
/// [desiredSize] is the desired size. If null, the result will be [originalSize].
/// Either the width OR height of [desiredSize] may be zero, in which case the
/// picture is scaled with regard to the aspect ratio and the opposite dimension.
/// Returns the calculated desired size and x/y scaling values.
ScaleAndSize scaleWithOneAspectMissing(Size originalSize, Size? desiredSize) {
  if (desiredSize == null) {
    desiredSize = originalSize;
  }

  var renderWidth = desiredSize.width > 0 ? desiredSize.width : null;
  var renderHeight = desiredSize.height > 0 ? desiredSize.height : null;
  double? xScale, yScale;

  if (renderWidth != null) {
    xScale = renderWidth / originalSize.width;
  }

  if (renderHeight != null) {
    yScale = renderHeight / originalSize.height;
  }

  xScale ??= yScale;
  yScale ??= xScale;

  renderWidth ??= originalSize.width * xScale!;
  renderHeight ??= originalSize.height * yScale!;

  desiredSize = Size(renderWidth, renderHeight);
  return ScaleAndSize(desiredSize, xScale!, yScale!);
}

class ScaleAndSize {
  final Size size;
  final double xScale, yScale;

  ScaleAndSize(this.size, this.xScale, this.yScale);
}
