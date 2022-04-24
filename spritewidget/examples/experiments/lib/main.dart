import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

void main() => runApp(ExperimentApp());

// The image map hold all of our image assets.
late ImageMap _images;

class ExperimentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Experiments',
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
  SoundController? _soundController;

  @override
  void initState() {
    super.initState();

    // Get our root asset bundle
    _loadAssets(rootBundle).then((_) => setState(() {}));
  }

  Menu _makeMenu(Size size, ui.Image? ninePatchImage, TextStyle style) {
    final MenuBuilder builder = MenuBuilder(size)
      ..verticalAlignment = MenuVertAlign.bottom
      ..textStyle = style
      ..bkgImage = ninePatchImage
      ..bkgNineSliceCenterRect = Rect.fromLTRB(17, 16, 180, 54)
      ..maxItemWidth = size.width / 2
      ..onPreSelected = ((_) => _soundController!.playFx('laser'))
      ..addItem('Play', onSelected: (_) => print('Play pressed'))
      ..addItem('Settings', enabled: false)
      ..addItem('Trail demo', onSelected: (_) => _trailDemo(size))
      ..addItem('Bolt test', onSelected: (_) => _fireBolt())
      ..addItem('Scale test', onSelected: (_) => _scaleTest());
    return builder.build();
  }

  Future<Null> _loadAssets(AssetBundle bundle) async {
    // Load images using an ImageMap
    _images = ImageMap(bundle);
    await _images.load(<String>[
      'assets/sun.png',
      'assets/fw_glossy_button.png',
      'assets/spark.png',
      'assets/lightning.png',
    ]);

    _soundController = SoundController();
    await _soundController!.loadAllFx(bundle, {
      'boing': 'assets/audio/boin.mp3',
      'hit': 'assets/audio/hit.wav',
      'hit-orig': 'assets/audio/hit-old1.wav',
      'laser': 'assets/audio/laser.wav',
      'levelup': 'assets/audio/levelup.wav',
    });
    await _soundController!.loadAllMusic(bundle, {
      'music': 'assets/audio/music.mp3',
      'spaceblasts': 'assets/audio/music_game.mp3',
    });

    final mediaQuery = MediaQuery.of(context);
    final usableSize = mediaQuery.padding.deflateSize(mediaQuery.size);
    rootNode = RootNode(usableSize);
    rootNode.soundController = _soundController!;
    Sprite sun = Sprite.fromImage(_images['assets/sun.png']!);
    sun.position = Offset(512, 512);
//        rootNode.addChild(sun);

    final size = Size(256, 0);
    final tigerPainter = await svgToPainter(
        rootBundle, 'assets/ghostscript_tiger.svg',
        desiredSize: size, renderAsImage: true);
    final tigerNode = Sprite.fromPainter(tigerPainter);
    tigerNode.position = Offset(128, 128);
    tigerNode.relativePositionAnchor = Offset.zero;
    tigerNode.scalePivot = tigerNode.rotationPivot = const Offset(.5, .5);
    tigerNode.motions.run(MotionRepeatForever(MotionSequence(<Motion>[
      MotionTween<double>(
          (v) => tigerNode.scale = v, .5, 1, .25, Curves.bounceOut),
      MotionTween<double>((v) => tigerNode.scale = v, 1, .5, .5),
      MotionTween<double>((v) => tigerNode.rotation = v, 360, 0, .75),
    ])));

//        tigerNode.motions.run(
//          MotionRepeatForever(
//            MotionTween<double>((v) => tigerNode.rotation = v, 359.9, 0, 1),
//          ),
//        );

    rootNode.addChild(tigerNode);

    final ninePatchImage = _images['assets/fw_glossy_button.png'];
    // -----
//        final nineSprite = NineSliceSprite(
//          ninePatchImage,
//          size: Size(400, 400),
//          centerRect: Rect.fromLTRB(17, 16, 180, 54),
//        );
//        nineSprite.position = Offset(0, 300);
//        nineSprite.pivot = Offset.zero;
//        rootNode.addChild(nineSprite);

    final style =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 40, shadows: [
      Shadow(
        blurRadius: 15,
        offset: Offset(0, 0),
        color: Colors.yellow,
      )
    ]);

    // -----
//        Label label = Label('Hello', textAlign: TextAlign.center, textStyle: style, layoutWidth: usableSize.width);
//        print('Label 1 - Natural width=${label.naturalWidth} height=${label.naturalHeight}');
//        label.position = Offset(0, 100);
//        rootNode.addChild(label);

    // -----
//        const lorem =
//            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec consectetur eleifend erat, eu placerat ligula consequat efficitur. Phasellus aliquam erat in suscipit ullamcorper. Sed vel quam a magna sollicitudin tristique molestie ullamcorper leo. Morbi ullamcorper libero leo, nec cursus velit commodo ut. Phasellus fermentum neque blandit, convallis turpis et, dapibus mauris. Donec nisl arcu, convallis nec est nec, auctor convallis nibh. Aenean nec accumsan felis, ac semper metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ut scelerisque tortor. Integer ac semper mauris. Aenean rutrum sed lorem in vulputate. Morbi libero urna, gravida nec mauris non, mollis luctus massa. In a magna leo. Mauris quis dui augue. Aliquam erat volutpat. In faucibus, augue sit amet venenatis dictum, nisi risus venenatis magna, id efficitur mauris nulla nec massa.';
//        Label label2 = Label(
//          lorem,
//          textAlign: TextAlign.left,
//          layoutWidth: usableSize.width,
//          maxLines: 5,
//        );
//        print('Label 2 - Natural width=${label2.naturalWidth} height=${label2.naturalHeight}');
//        label2.position = Offset(0, 300);
//        rootNode.addChild(label2);

    // -----
//        const buttonWidth = 200.0;
//        Label buttonLabel = Label(
//          'Play',
//          textAlign: TextAlign.center,
//          textStyle: style,
//          layoutWidth: buttonWidth,
//        );
//        final buttonBkg = NineSliceSprite(
//          ninePatchImage,
//          size: Size(buttonWidth, buttonLabel.naturalHeight * 2),
//          centerRect: Rect.fromLTRB(17, 16, 180, 54),
//        );
//        buttonBkg.position = Offset(0, 0);
//        buttonLabel.position = Offset(0, (buttonBkg.size.height - buttonLabel.naturalHeight) / 2);
//        final button = ButtonWithBackgroundAndLabel(
//          background: buttonBkg,
//          label: buttonLabel,
//          onTriggered: (event) => print('Triggered'),
//        );
//        button.position = Offset(100, 40);
//        button.enabled = true;
//        rootNode.addChild(button);

    rootNode.addChild(_makeMenu(usableSize, ninePatchImage, style));

//        rootNode.addChild(ClosurePaintNode((canvas) {
//          final paint = Paint()
//            ..color = Colors.red
//            ..style = PaintingStyle.stroke
//            ..strokeWidth = 10.0;
//          canvas.drawRect(Rect.fromLTWH(0, 0, usableSize.width, usableSize.height), paint);
//        }));

    final imagePainter =
        ImagePainter(_images['assets/sun.png']!, size: Size(60, 60));
    final imagePaint = Paint();
    rootNode.addChild(Node()
      ..customPainter = (canvas) => imagePainter.paint(canvas, imagePaint));

    FpsLabel fpsNode = FpsLabel();
    fpsNode.position = Offset(0, 0);
    rootNode.addChild(fpsNode);

    assetsLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!assetsLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Experiments'),
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

  void _scaleTest() {
    final node = Node(Size(100, 100))
      ..position = Offset(100, 100)
      ..scalePivot = Sprite.centerOffset;
    rootNode.addChild(node);
    final sprite = Sprite.fromPainter(RectPainter(Size(100, 100)))
      ..scalePivot = Sprite.centerOffset;
    node.addChild(sprite);
    node.motions.run(MotionSequence([
      MotionTween((s) => node.scale = s, 0.0, 1.0, 2.0),
      MotionDelay(1.0),
      MotionRemoveNode(sprite),
    ]));
  }

  void _trailDemo(Size usableSize) {
    final leftX = usableSize.width * .25;
    final upperY = usableSize.height * .25;
    final rightX = usableSize.width * .75;
    final lowerY = usableSize.height * .75;
    final points = [
      Offset(leftX, upperY),
      Offset(rightX, upperY),
      Offset(rightX, lowerY),
      Offset(leftX, lowerY),
      Offset(leftX, upperY),
    ];
    final sprite = Sprite.fromPainter(DotPainter(10));
    final trail = TrailEffectNode(5)..addChild(sprite);
    trail.motions.run(MotionSequence([
      MotionSpline((p) => sprite.position = p, points, 3.0),
      MotionDelay(1.0),
      MotionRemoveNode(trail),
    ]));
    rootNode.addChild(trail);
  }

  void _fireBolt() {
    final duration = 3.0;
    var image = _images['assets/lightning.png']!;
    final ends = [
      Offset(200, 400),
      Offset(100, 400),
      Offset(300, 400),
    ];
    final effect = LightningEffect(Offset(10, 10), ends, SpriteTexture(image));
    effect.motions.run(MotionSequence([
      MotionDelay(duration),
      MotionRemoveNode(effect),
    ]));
    rootNode.addChild(effect);
    // TODO Ends should be sorted by length? and matched with the branch points.
    // We don't want paths to cross.

    // var effectLine = EffectLine(
    //   texture: SpriteTexture(image),
    //   fadeDuration: 1.1,
    //   fadeAfterDelay: duration - 0.1,
    //   // widthGrowthSpeed: 1.0,
    //   transferMode: BlendMode.plus,
    //   // textureLoopLength: image.width.toDouble(),
    //   minWidth: 30.0,
    //   maxWidth: 30.0,
    //   widthMode: EffectLineWidthMode.linear,
    //   animationMode: EffectLineAnimationMode.scroll,
    //   scrollSpeed: 2.1,
    //   // colorSequence: ColorSequence.fromStartAndEndColor(
    //   //     const Color(0xff00ffff), const Color(0xffffffff)),
    // )
    //   ..addPoint(Offset(10, 10))
    //   ..addPoint(Offset(30, 30))
    //   ..addPoint(Offset(50, 50))
    //   ..addPoint(Offset(100, 100))
    //   ..addPoint(Offset(200, 200));
    // effectLine.motions.run(MotionSequence([
    //   MotionDelay(duration),
    //   MotionCallFunction(() => effectLine.addPoint(Offset(400, 400))),
    //   MotionDelay(duration),
    //   MotionRemoveNode(effectLine),
    // ]));
    // rootNode.addChild(effectLine);
  }
}

class RootNode extends Node {
  RootNode(Size size) {
    this.size = size;
  }

  double tot = 0, tot2 = 0;
  late SoundController soundController;
  bool music = false;

  @override
  void update(double dt) {
    super.update(dt);

//    tot += dt;
//    tot2 += dt;
//    if (!music) {
//      music = true;
//      soundController.playMusic('spaceblasts', repeat: true);
//    }
//
//    if (tot >= .5 && tot2 <= 5) {
//      tot = 0;
//      soundController.playFx('laser');
//      soundController.playFx('hit');
//    }
//    if (tot2 >= .75) {
//      tot2 = 0;
//      soundController.play('hit');
//    }
  }
}

class LightningEffect extends Node {
  LightningEffect(Offset start, List<Offset> ends, SpriteTexture texture) {
    // Take the longest line as the main bolt. Everything else will branch from
    // this one.
    final startPt = Point(start.dx, start.dy);
    var maxDistance = 0.0;
    Offset mainEnd = Offset.zero;
    for (Offset sampleEnd in ends) {
      final distance = startPt.distanceTo(Point(sampleEnd.dx, sampleEnd.dy));
      if (distance >= maxDistance) {
        maxDistance = distance;
        mainEnd = sampleEnd;
      }
    }

    final mainBolt = LightningBolt(start, mainEnd, texture);
    addChild(mainBolt);

    final numBranches = ends.length - 1;
    final branchPoints = List.generate(numBranches, (index) => randomDouble())
      ..sort();

    for (int i = 0; i < ends.length; i++) {
      Offset end = ends[i];
      if (end != mainEnd) {
        Offset boltStart = mainBolt.getPointAlongLine(branchPoints[i]);
        addChild(LightningBolt(boltStart, end, texture));
      }
    }
  }
}

class LightningBolt extends EffectLine {
  final Offset start;
  final Offset end;

  LightningBolt(this.start, this.end, SpriteTexture texture)
      : super(
          texture: texture,
          transferMode: BlendMode.plus,
          minWidth: 30.0,
          maxWidth: 30.0,
          widthMode: EffectLineWidthMode.linear,
          animationMode: EffectLineAnimationMode.scroll,
          scrollSpeed: 2.1,
        ) {
    addPoint(start);
    addPoint(end);
  }

  /// Returns the point where the bolt is at a given fraction of the way through the bolt.
  /// A [t] of zero will return the start of the bolt, and 1 will return the end.
  Offset getPointAlongLine(double t) {
    return Offset(
        start.dx + t * (end.dx - start.dx), start.dy + t * (end.dy - start.dy));
  }
}
