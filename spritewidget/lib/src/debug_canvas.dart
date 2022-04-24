import 'dart:typed_data';
import 'dart:ui';

class DebugCanvas implements Canvas {
  Canvas canvas;
  int _creationMicros = DateTime.now().microsecondsSinceEpoch;
  int _startMicros = 0;
  int totalMicros = 0;

  DebugCanvas(this.canvas);

  void _start() {
    _startMicros = DateTime.now().microsecondsSinceEpoch;
  }

  void _end(String apiName) {
    final duration = DateTime.now().microsecondsSinceEpoch - _startMicros;
    totalMicros += duration;
    print('$apiName: $duration us');
  }

  void printSummary() {
    print('Total api: $totalMicros us');
    final duration = DateTime.now().microsecondsSinceEpoch - _creationMicros;
    print('Total time alive: $duration us');
  }

  void _checkPaint(Paint paint) {
//    print('Paint for call below is ${paint.toString()}');
//    if (paint.color != null && paint.color.alpha != 255) {
//      paint.color = Color.fromARGB(255, paint.color.red, paint.color.green, paint.color.blue);
//    }
  }

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    _start();
    canvas.clipPath(path, doAntiAlias: doAntiAlias);
    _end('clipPath');
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    _start();
    canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
    _end('clipRRect');
  }

  @override
  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {
    _start();
    canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
    _end('clipRect');
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
    _end('drawArc');
  }

  @override
  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color>? colors, BlendMode? blendMode, Rect? cullRect, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawAtlas(
        atlas, transforms, rects, colors, blendMode, cullRect, paint);
    _end('drawAtlas');
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawCircle(c, radius, paint);
    _end('drawCircle');
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    _start();
    canvas.drawColor(color, blendMode);
    _end('drawColor');
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawDRRect(outer, inner, paint);
    _end('drawDRRect');
  }

  @override
  void drawImage(Image image, Offset offset, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawImage(image, offset, paint);
    _end('drawImage');
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawImageNine(image, center, dst, paint);
    _end('drawImageNine');
  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawImageRect(image, src, dst, paint);
    _end('drawImageRect');
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawLine(p1, p2, paint);
    _end('drawLine');
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawOval(rect, paint);
    _end('drawOval');
  }

  @override
  void drawPaint(Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawPaint(paint);
    _end('drawPaint');
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    _start();
    canvas.drawParagraph(paragraph, offset);
    _end('drawParagraph');
  }

  @override
  void drawPath(Path path, Paint paint) {
    _checkPaint(paint);
    _start();
//    print('*** Path length ${path.computeMetrics().length}');
    canvas.drawPath(path, paint);
//    canvas.drawPath(path, new Paint());
    _end('drawPath');
  }

  @override
  void drawPicture(Picture picture) {
    _start();
    canvas.drawPicture(picture);
    _end('drawPicture');
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawPoints(pointMode, points, paint);
    _end('drawPoints');
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawRRect(rrect, paint);
    _end('drawRRect');
  }

  @override
  void drawRawAtlas(Image atlas, Float32List rstTransforms, Float32List rects,
      Int32List? colors, BlendMode? blendMode, Rect? cullRect, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawRawAtlas(
        atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);
    _end('drawRawAtlas');
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawRawPoints(pointMode, points, paint);
    _end('drawRawPoints');
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawRect(rect, paint);
    _end('drawRect');
  }

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {
    _start();
    canvas.drawShadow(path, color, elevation, transparentOccluder);
    _end('drawShadow');
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.drawVertices(vertices, blendMode, paint);
    _end('drawVertices');
  }

  @override
  int getSaveCount() {
    _start();
    final v = canvas.getSaveCount();
    _end('getSaveCount');
    return v;
  }

  @override
  void restore() {
    _start();
    canvas.restore();
    _end('restore');
  }

  @override
  void rotate(double radians) {
    _start();
    canvas.rotate(radians);
    _end('rotate');
  }

  @override
  void save() {
    _start();
    canvas.save();
    _end('save');
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    _checkPaint(paint);
    _start();
    canvas.saveLayer(bounds, paint);
    _end('saveLayer');
  }

  @override
  void scale(double sx, [double? sy]) {
    _start();
    canvas.scale(sx, sy);
    _end('scale');
  }

  @override
  void skew(double sx, double sy) {
    _start();
    canvas.skew(sx, sy);
    _end('skew');
  }

  @override
  void transform(Float64List matrix4) {
    _start();
    canvas.transform(matrix4);
    _end('transform');
  }

  @override
  void translate(double dx, double dy) {
    _start();
    canvas.translate(dx, dy);
    _end('translate');
  }
}
