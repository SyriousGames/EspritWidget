import 'dart:ui';

import 'package:spritewidget/spritewidget.dart';

class TrailEffectNode extends Node {
  // Circular list of frames.
  final int numTrailFrames;
  final List<Picture?> _previousFrames;
  int _nextFrameIdx = 0;
  Rect? _bounds;
  final int numFramesBetweenCapture;
  // Paints for each frame. Index 0 is for the most recent previous frame.
  // Each paint gets progressively more transparent.
  final List<Paint> _transparentPaint;
  int _framesSinceLastCapture = 0;

  TrailEffectNode(this.numTrailFrames,
      {Size size = Size.zero, this.numFramesBetweenCapture = 1})
      : _previousFrames = List.filled(numTrailFrames, null),
        _transparentPaint = List.generate(
            numTrailFrames,
            (idx) => Paint()
              ..color = Color.fromRGBO(
                  0, 0, 0, 1.0 - ((idx + 1) / (numTrailFrames + 1)))),
        super(size) {
    _bounds =
        size == Size.zero ? null : Rect.fromLTWH(0, 0, size.width, size.height);
  }

  @override
  void visit(Canvas canvas) {
    if (!visible) return;

    final recorder = PictureRecorder();
    final pictureCanvas = Canvas(recorder);

    // Draw the children
    super.visit(pictureCanvas);

    final currentFrame = recorder.endRecording();

    // Perform the actual rendering.
    prePaint(canvas);
    canvas.drawPicture(currentFrame);

    // Paint the previous frames from most recent first.
    int frameIdx = _nextFrameIdx - 1;
    for (int i = 0; i < numTrailFrames; i++, --frameIdx) {
      if (frameIdx < 0) {
        frameIdx = numTrailFrames - 1;
      }

      final priorFrame = _previousFrames[frameIdx];
      if (priorFrame != null) {
        canvas.saveLayer(_bounds, _transparentPaint[i]);
        canvas.drawPicture(priorFrame);
        canvas.restore();
      }
    }

    postPaint(canvas);

    ++_framesSinceLastCapture;
    if (_framesSinceLastCapture >= numFramesBetweenCapture) {
      // Save this frame.
      _previousFrames[_nextFrameIdx] = currentFrame;
      ++_nextFrameIdx;
      if (_nextFrameIdx >= numTrailFrames) {
        _nextFrameIdx = 0;
      }

      _framesSinceLastCapture = 0;
    }
  }
}
