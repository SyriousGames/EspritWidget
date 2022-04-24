import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

late Function(Duration) _flutterOnBeginFrame;
late Function() _flutterOnDrawFrame;

void main() {
  runApp(NopApp());

  // Runs after Flutter's scheduled microtasks
  Timer.run(() {
    SchedulerBinding.instance!.addPersistentFrameCallback(tickPersistent);
//    print('onBeginFrame=${ui.window.onBeginFrame}');
//    _flutterOnBeginFrame = ui.window.onBeginFrame;
//    _flutterOnDrawFrame = ui.window.onDrawFrame;
//    ui.window.onBeginFrame = tick;
//    ui.window.onDrawFrame = draw;
//    ui.window.scheduleFrame();
  });
}

int? _microsOfLastUpdate;
int _updateCount = 0;
void tick(Duration duration) {
  ++_updateCount;
  final now = DateTime.now().microsecondsSinceEpoch;
  if (_microsOfLastUpdate != null) {
    final microsSinceLastUpdate = now - _microsOfLastUpdate!;
    if (microsSinceLastUpdate > 18000) {
      print(
          'update[$_updateCount] Time since last update: $microsSinceLastUpdate us');
    } else {
      print('update[$_updateCount]');
    }
  }

  _microsOfLastUpdate = now;

  _flutterOnBeginFrame(duration);
  ui.window.scheduleFrame();
}

void tickPersistent(Duration duration) {
  ++_updateCount;
  final now = DateTime.now().microsecondsSinceEpoch;
  if (_microsOfLastUpdate != null) {
    final microsSinceLastUpdate = now - _microsOfLastUpdate!;
    if (microsSinceLastUpdate > 18000) {
      print(
          'update[$_updateCount] Time since last update: $microsSinceLastUpdate us');
    } else {
//      print('update[$_updateCount]');
    }
  }

  _microsOfLastUpdate = now;
  ui.window.scheduleFrame();
}

void draw2() {
  final Rect paintBounds = Rect.fromLTWH(0.0, 0.0, 400, 400);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder, paintBounds);

  canvas.drawCircle(
      Offset(400, 400),
      400,
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red);

  final ui.Picture picture = recorder.endRecording();
  final ui.SceneBuilder builder = ui.SceneBuilder()
    ..addPicture(ui.Offset.zero, picture);
  ui.window.render(builder.build());
  ui.window.scheduleFrame();
}

void draw() {
  // Flutter draws on top of us.
  _flutterOnDrawFrame();

  final Rect paintBounds = Rect.fromLTWH(0.0, 0.0, 400, 400);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder, paintBounds);

  canvas.drawCircle(
      Offset(400, 400),
      400,
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red);

  final ui.Picture picture = recorder.endRecording();
  final ui.SceneBuilder builder = ui.SceneBuilder()
    ..addPicture(ui.Offset.zero, picture);
  ui.window.render(builder.build());
  ui.window.scheduleFrame();
}

class NopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MaterialContextWidget(),
    );
  }
}

class MaterialContextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 5), () => displayDialog(context));
    return SizedBox.shrink();
  }
}

void displayDialog(BuildContext context) {
  final dialog = AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
  );

  showDialog(builder: (context) => dialog, context: context);
}
