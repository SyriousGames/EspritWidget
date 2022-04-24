import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'debug_canvas.dart';
import 'node.dart';

class LottieAnimationNode extends Node {
  late LottieDrawable _drawable;
  LottieDrawable get lottieDrawable => _drawable;

  void Function(LottieAnimationNode)? _onSequenceDone;
  void Function(LottieAnimationNode)? _onCompletion;

  /// Elapsed animation time, in seconds.
  double _elapsedTime = 0;
  bool _running = false;
  BoxFit boxFit;
  late double _startSeconds;
  late double _endSeconds;
  late double _segmentDurationSeconds;
  late double _totalDurationSeconds;
  late bool _looped;
  int _numLoops = 0;
  int _numLoopsRemaining = 0;
  bool debug = false;

  /// If either [desiredSize.width] or [desiredSize.height] is zero, it is calculated using the opposite dimension and
  /// aspect ratio of [lottieDrawable]. This [Node]'s size is set to the calculated size.
  LottieAnimationNode(LottieComposition composition, Size desiredSize,
      {this.boxFit = BoxFit.contain, bool enableMergePaths = false}) {
    _drawable = LottieDrawable(composition, enableMergePaths: enableMergePaths);
    //print('Lottie ${_drawable.size}');
    this.desiredSize = desiredSize;
    // composition.markers.forEach((marker) =>
    //     print('Marker: ${marker.name} ${marker.startFrame} ${marker.end}'));
    if (Lottie.traceEnabled) {
      composition.performanceTrackingEnabled = true;
    }
  }

  /// Initiates loading a [LottieComposition] in the background from the given JSON asset name.
  static Future<LottieComposition> loadFromJson(
      AssetBundle bundle, String jsonAssetName) async {
    final jsonData = await bundle.load(jsonAssetName);
    return LottieComposition.fromByteData(jsonData);
  }

  /// Sets the desired size of the animation.
  ///
  /// If either [desiredSize.width] or [desiredSize.height] is zero, it is calculated using the opposite dimension and
  /// aspect ratio of [lottieDrawable]. This [Node]'s size is set to the calculated size.
  set desiredSize(Size desiredSize) {
    double renderWidth = desiredSize.width;
    double renderHeight = desiredSize.height;

    if (renderWidth == 0) {
      renderWidth =
          _drawable.size.width * (renderHeight / _drawable.size.height);
    } else if (renderHeight == 0) {
      renderHeight =
          _drawable.size.height * (renderWidth / _drawable.size.width);
    }

    size = Size(renderWidth, renderHeight);
  }

  /// Start the animation.
  ///
  /// By default the animation will play in its entirety. [onSequenceDone] and [onCompletion] will be called when the sequence is finished.
  /// If [looped] is true, the animation will continuously loop and [onSequenceDone] will be called at the end of each loop
  /// cycle, but [onCompletion] will never be called. If [startMarker] or [startMarkerName] is set, it will play the animation starting at the given marker. If
  /// the start marker is given and [endMarker] and [endMarkerName] is not set, the animation will play for the duration
  /// specified in the start marker, otherwise it will play up to the end marker. [looped] also affects marked sequences.
  /// If [numLoops] is > 0, the animation will
  /// loop the specified number of times - as with [looped] - and [onCompletion] will be called at the end of the looping.
  void start(
      {Marker? startMarker,
      Marker? endMarker,
      String? startMarkerName,
      String? endMarkerName,
      bool looped = false,
      int numLoops = 0,
      void Function(LottieAnimationNode)? onSequenceDone,
      void Function(LottieAnimationNode)? onCompletion}) {
    if (startMarkerName != null) {
      startMarker = _drawable.composition.getMarker(startMarkerName);
      assert(startMarker != null, '$startMarkerName not found');
    }

    if (startMarker != null && endMarkerName != null) {
      endMarker = _drawable.composition.getMarker(endMarkerName);
      assert(endMarker != null, '$endMarkerName not found');
    }

    if (startMarker == null) {
      _startSeconds = _convertFrameToSeconds(_drawable.composition.startFrame);
      _endSeconds = _convertFrameToSeconds(_drawable.composition.endFrame);
    } else {
      // If we don't have an endMarker, use the startMarker duration.
      if (endMarker == null) {
        assert(startMarker.durationFrames != 0);
        _endSeconds = _convertFrameToSeconds(
            startMarker.startFrame + startMarker.durationFrames);
      } else {
        // Have to add 1 frame here. For example, if the endMarker = startMarker (0 difference), the duration is 1 frame.
        _endSeconds = _convertFrameToSeconds(endMarker.startFrame + 1);
      }

      _startSeconds = _convertFrameToSeconds(startMarker.startFrame);
    }

    _segmentDurationSeconds = _endSeconds - _startSeconds;
    _totalDurationSeconds =
        _convertFrameToSeconds(_drawable.composition.durationFrames);

    _looped = looped;
    _numLoops = numLoops;
    _onSequenceDone = onSequenceDone;
    _onCompletion = onCompletion;

    reset();
    resume();
  }

  /// Restart with the original [start()] animation parameters.
  void restart() {
    reset();
    resume();
  }

  void stop() {
    pause();
    reset();
  }

  void resume() => _running = true;
  void pause() => _running = false;
  void reset() {
    _elapsedTime = 0;
    _numLoopsRemaining = _numLoops;
  }

  double _convertFrameToSeconds(double frame) {
    return frame / _drawable.composition.frameRate;
  }

  // Unoptimized code.
//  @override
//  void update(double dt) {
//    if (_running) {
//      if (_elapsedTime > _segmentDurationSeconds) {
//        if (_onSequenceDone != null) {
//          _onSequenceDone(this);
//        }
//
//        if (_numLoopsRemaining > 0) {
//          --_numLoopsRemaining;
//        }
//
//        if (_looped || _numLoopsRemaining > 0) {
//          _elapsedTime = 0;
//        } else {
//          _running = false;
//
//          if ((!_looped || _numLoopsRemaining == 0) && _onCompletion != null) {
//            _onCompletion(this);
//          }
//        }
//      }
//
//      // If it is still running, update the progress.
//      if (_running) {
//        // For progress, we need the absolute 0..1 progress in the entire animation.
//        final progress = (_startSeconds + _elapsedTime) / _totalDurationSeconds;
//        //print(
//        //    'Playing frame ${progress * _drawable.composition.durationFrames} endFrame=${(_endSeconds * _drawable.composition.frameRate) - 1}');
//
//        final startMicros = debug ? DateTime.now().microsecondsSinceEpoch : 0;
//        _drawable.setProgress(progress);
//        if (debug) {
//          final duration = DateTime.now().microsecondsSinceEpoch - startMicros;
//          print('setProgress: $duration us');
//        }
//
//        _elapsedTime += dt;
//      }
//    }
//  }
//
//  @override
//  void paint(Canvas canvas) {
//    final fitRect = Offset.zero & size;
//    var debugCanvas;
//    if (debug) {
//      debugCanvas = DebugCanvas(canvas);
//      canvas = debugCanvas;
//    }
//    _drawable.draw(canvas, fitRect, fit: boxFit);
//
//    if (debug) {
//      debugCanvas.printSummary();
//    }
//
//    if (Lottie.traceEnabled) {
//      _drawable.composition.performanceTracker.logRenderTimes();
//    }
//  }

  // Alternate drawing code to try to optimize for dirty flag. Helps if animation is still for more than one frame.
  Picture? _renderPicture;
  @override
  void update(double dt) {
    if (_running) {
      if (_elapsedTime > _segmentDurationSeconds) {
        if (_onSequenceDone != null) {
          _onSequenceDone!(this);
        }

        if (_numLoopsRemaining > 0) {
          --_numLoopsRemaining;
        }

        if (_looped || _numLoopsRemaining > 0) {
          _elapsedTime = 0;
        } else {
          _running = false;

          if ((!_looped || _numLoopsRemaining == 0) && _onCompletion != null) {
            _onCompletion!(this);
          }
        }
      }

      // If it is still running, update the progress.
      if (_running) {
        // For progress, we need the absolute 0..1 progress in the entire animation.
        final progress =
            min(1.0, (_startSeconds + _elapsedTime) / _totalDurationSeconds);
        //print(
        //    'Playing frame ${progress * _drawable.composition.durationFrames} endFrame=${(_endSeconds * _drawable.composition.frameRate) - 1}');
        final isDirty = _drawable.setProgress(progress);
        _elapsedTime += dt;
        if (isDirty || _renderPicture == null) {
          // Since the lottie might only be at 24 FPS, we don't always need to draw. Only update the picture if it's dirty.
          _renderToPicture();
        }
      }
    }
  }

  void _renderToPicture() {
    final recorder = PictureRecorder();
    var canvas = Canvas(recorder);
    if (debug) {
      canvas = DebugCanvas(canvas);
    }

    final fitRect = Offset.zero & size;
    _drawable.draw(canvas, fitRect, fit: boxFit);

    _renderPicture = recorder.endRecording();

    if (debug) {
      (canvas as DebugCanvas).printSummary();
    }
  }

  @override
  void paint(Canvas canvas) {
    if (_renderPicture != null) {
      canvas.drawPicture(_renderPicture!);
    }
  }
}
