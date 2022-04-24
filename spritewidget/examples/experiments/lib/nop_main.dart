import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

void main() {
  runApp(NopApp());
//  Ticker((dur) => tick(dur)).start();
}

int? _microsOfLastUpdate;
int _updateCount = 0;

void tick(Duration duration) {
  ++_updateCount;
  final now = DateTime.now().microsecondsSinceEpoch;
  if (_microsOfLastUpdate != null) {
    final microsSinceLastUpdate = now - _microsOfLastUpdate!;
    if (microsSinceLastUpdate > 17000) {
      print(
          'update[$_updateCount] Time since last update: $microsSinceLastUpdate us');
    } else {
      print('update[$_updateCount]');
    }
  }

  _microsOfLastUpdate = now;
}

class NopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No-op game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late RootNode rootNode;
  bool assetsLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadAssets(rootBundle).then((_) => setState(() {
          final mediaQuery = MediaQuery.of(context);
          final usableSize = mediaQuery.padding.deflateSize(mediaQuery.size);
          rootNode = RootNode(usableSize);

          FpsLabel fpsNode = FpsLabel();
          fpsNode.position = Offset(0, 0);
          rootNode.addChild(fpsNode);
          assetsLoaded = true;
        }));
  }

  Future<Null> _loadAssets(AssetBundle bundle) async {}

  @override
  Widget build(BuildContext context) {
    if (!assetsLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text('No-op game'),
          backgroundColor: Colors.black,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
          ),
        ),
      );
    }

    return Container(
      padding: MediaQuery.of(context).padding,
      child: SpriteWidget(rootNode, SpriteBoxTransformMode.nativePoints),
    );
  }
}

class RootNode extends Node {
  RootNode(Size size) {
    this.size = size;
  }

  int? _microsOfLastUpdate;
  int _updateCount = 0;

  @override
  void update(double dt) {
    super.update(dt);
    ++_updateCount;
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_microsOfLastUpdate != null) {
      final microsSinceLastUpdate = now - _microsOfLastUpdate!;
      if (microsSinceLastUpdate > 17000) {
        print(
            'update[$_updateCount] Time since last update: $microsSinceLastUpdate us');
      } else {
        print('update[$_updateCount]');
      }
    }

    _microsOfLastUpdate = now;
  }

  int? _microsOfLastPaint;

  @override
  void paint(Canvas canvas) {
    super.paint(canvas);
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_microsOfLastPaint != null) {
      final microsSinceLastPaint = now - _microsOfLastPaint!;
      if (microsSinceLastPaint > 17000) {
//        print('Time since last paint: $microsSinceLastPaint us');
      }
    }

    _microsOfLastPaint = now;
  }
}
