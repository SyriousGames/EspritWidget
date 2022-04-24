import 'dart:async';
import 'dart:math';

import 'package:demo/mortar_emitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:spritewidget_flint_particles/flint_particles.dart' as ps;

void main() => runApp(GameApp());

class GameApp extends StatelessWidget {
  // TODO Orientation changes are not locked. If the screen is landscape before startup, it starts up landscape.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: TopWidget(),
    );
  }
}

class TopWidget extends StatefulWidget {
  @override
  _TopWidgetState createState() => _TopWidgetState();
}

class _TopWidgetState extends State<TopWidget> {
  RootNode? _rootNode;
  bool _assetsLoaded = false;

  @override
  Widget build(BuildContext context) {
    // See issue https://github.com/flutter/flutter/issues/25827. Size might be zero initially.
    if (_rootNode == null && MediaQuery.of(context).size.width != 0) {
      _rootNode = RootNode(context);
      _rootNode!.init().then((_) {
        // Set the first demo to run only after the SpriteBox has been laid out.
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          await _rootNode!._runDemo(_rootNode!.demos[0]);
          setState(() {});
        });
        setState(() => _assetsLoaded = true);
      });
    }

    if (!_assetsLoaded || _rootNode == null) {
      // Loading screen
      return Scaffold(
        body: Container(
          color: Colors.black,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          alignment: Alignment.center,
          child: Text('Loading...'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child:
                  SpriteWidget(_rootNode!, SpriteBoxTransformMode.nativePoints),
            ),
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Scrollbar(
                    child: ListView.builder(
                        itemCount: _rootNode!.demos.length,
                        itemBuilder: (_, i) {
                          final demo = _rootNode!.demos[i];
                          return ListTile(
                            title: Text(demo.name),
                            onTap: () async {
                              await _rootNode!._runDemo(demo);
                              setState(() {});
                            },
                            selected: demo.selected,
                          );
                        }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoItem {
  String name;
  bool selected = false;
  Future<Node> Function() nodeCreator;

  _DemoItem(this.name, this.nodeCreator);
}

const flintLogoName = 'assets/images/flint_logo.png';
const flintLogoOrangeName = 'assets/images/flint_logo_orange.png';
const particleSpriteSheetName = 'assets/images/particles.png';
const rainBkgName = 'assets/images/rain_bkg.png';
const snowFgName = 'assets/images/snow_fg.png';
const snowBkgName = 'assets/images/snow_bkg.png';
const flintLogo320x80Name = 'assets/images/flint_logo_black_320x80.png';
const particlesWordBlack320x80Name =
    'assets/images/particles_word_black_320x80.png';
const icePlanetName = 'assets/images/ice_planet.png';

class RootNode extends Node {
  late List<_DemoItem> demos;
  final GameContext _game;
  late Node _sceneLayer;
  late SpriteSheet _particleSpriteSheet;
  Node? _demoNode;

  /// Called after Flutter context is fully setup.
  RootNode(BuildContext flutterContext)
      : _game = GameContext(flutterContext),
        super(Size.zero) {
    demos = [
      _DemoItem('Chrysanthemum Firework', _createChrysanthemumFirework),
      _DemoItem('Catherine Wheel', _createCatherineWheel),
      _DemoItem('Brownian Motion', _createBrownianMotion),
      _DemoItem('Fire and Smoke', _createFireAndSmoke),
      _DemoItem('Confetti', _createConfetti),
      _DemoItem('Tinder Box', _createTinderBox),
      _DemoItem('Logo Morph', _createLogoMorph),
      _DemoItem('Snowfall', _createSnowfall),
      _DemoItem('Simple Firework', _createSimpleFirework),
      _DemoItem(
          'Simple Firework with Trail', _createSimpleFireworkWithTrailEffect),
      _DemoItem('Simple Red Firework with Trail',
          _createSimpleRedFireworkWithTrailEffect),
      _DemoItem('Simple Green Firework with Trail',
          _createSimpleGreenFireworkWithTrailEffect),
      _DemoItem('Simple Firework with Multi-color Trail',
          _createSimpleFireworkWithMultiColorTrailEffect),
      _DemoItem('Sparkler', _createSparkler),
      _DemoItem('Flocking', _createFlocking),
      _DemoItem('Logo Firework', _createLogoFirework),
      _DemoItem('Rain', _createRain),
      _DemoItem('Gravity Well', _createGravityWell),
      _DemoItem('Mutual Gravity', _createMutualGravity),
      _DemoItem('Logo On Fire', _createLogoOnFire),
      _DemoItem('Pachinko', _createPachinko),
      //_DemoItem('Still Particle', _createStillParticle),
    ];
  }

  Future<void> init() async {
    // TODO Should we really look at the SpriteBox size instead? Problem: SpriteBox is not created at this point.
    // TODO Maybe an asset-loading phase and then scene building phase. Scene building would only occur when it is
    // added to a SpriteBox and the SpriteBox has a size.
    _game.mediaQuery = MediaQuery.of(_game.flutterContext);
    _game.usableSize =
        _game.mediaQuery.padding.deflateSize(_game.mediaQuery.size);

    await _game.images.load(<String>[
      flintLogoName,
      flintLogoOrangeName,
      particleSpriteSheetName,
      rainBkgName,
      snowFgName,
      snowBkgName,
      flintLogo320x80Name,
      particlesWordBlack320x80Name,
      icePlanetName,
    ]);

    String particlesJson =
        await rootBundle.loadString('assets/images/particles.json');
    _particleSpriteSheet =
        SpriteSheet(_game.images[particleSpriteSheetName]!, particlesJson);

    _sceneLayer = Node();
    addChild(_sceneLayer);

    FpsLabel fpsNode = FpsLabel();
    fpsNode.position = Offset(0, 0);
    addChild(fpsNode);
  }

  Future<void> _runDemo(_DemoItem demo) async {
    if (demo.selected) {
      return;
    }

    demos.forEach((demo) => demo.selected = false);
    demo.selected = true;
    if (_demoNode != null) {
      _sceneLayer.removeChild(_demoNode!);
    }

    _demoNode = await demo.nodeCreator();
    _sceneLayer.addChild(_demoNode!);
  }

  Future<Node> _createStillParticle() async {
    const name = 'particles/fire_blob';
    final tex = _particleSpriteSheet[name];
    final emitter = ps.Emitter(_particleSpriteSheet, defaultParticleName: name);
    emitter.counter = ps.Blast(1);
    // Note that particle.x/y is 0/0 relative to this node.
    final rotation = -50.0;
    final scale = 8.0;
    final px = 10.0;
    final py = 25.0;
    emitter.addInitializer(ps.Position(ps.PointZone(Point(px, py))));
    emitter.addInitializer(ps.ScaleAllInit(scale, scale));
    emitter.addInitializer(ps.Rotation(rotation, rotation));
    emitter.start();

    Node parent = Node()..position = Offset(250, 250);
    parent.addChild(emitter);
    parent.addChild(Node()
      ..customPainter = (canvas) {
        // Flint particles in AS3 were drawn around the center of the particle, including rotation and scaling.
        // The particle x,y was assumed to be at the center of the particle.

        canvas.translate(px, py);
        // Draw crosshairs at the center point the center point is 0, 0 wrt the parent node.
        final hairPaint = Paint()..color = Color.fromARGB(0xe0, 0xff, 0, 0);
        final halfWidth = tex!.size.width / 2;
        final halfHeight = tex.size.height / 2;
        canvas.drawLine(Offset(-100, 0), Offset(100, 0), hairPaint);
        canvas.drawLine(Offset(0, -100), Offset(0, 100), hairPaint);

        // Draw a brighter rect at the original unrotated/unscaled position.
        canvas.translate(-halfWidth, -halfHeight);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, tex.size.width, tex.size.height),
            Paint()
              ..color = Color.fromARGB(0xe0, 0xff, 0xff, 0xff)
              ..style = PaintingStyle.stroke);

        // Now scale and rotate and draw a rect in the expected position.
        canvas.translate(halfWidth, halfHeight);
        canvas.scale(scale);
        canvas.rotate(convertDegrees2Radians(rotation));
        canvas.translate(-halfWidth, -halfHeight);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, tex.size.width, tex.size.height),
            Paint()
              ..color = Color.fromARGB(0x7f, 0xff, 0xff, 0xff)
              ..style = PaintingStyle.stroke);
      });
    return parent;
  }

  Future<ps.Emitter> _createSparkler() async {
    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/horizontal_line_12px_glow');
    emitter.counter = ps.Steady(2000);

    emitter.addInitializer(ps.ColorInit(Color(0xFFFFCC00), Color(0xFFFFff00)));
    emitter.addInitializer(ps.Velocity(ps.DiscZone(Point(0.0, 0.0), 350, 200)));
    emitter.addInitializer(ps.Lifetime(0.2, 0.4));

    emitter.addAction(ps.Age());
    emitter.addAction(ps.Move());
    emitter.addAction(ps.RotateToDirection());

    final areaSize = spriteBox!.size;
    final left = areaSize.width * 0.10;
    final top = areaSize.height * 0.10;
    final right = areaSize.width * 0.90;
    final bottom = areaSize.height * 0.90;
    final center = Offset(areaSize.width / 2, areaSize.height / 2);
    final points = [
      Offset(left, top),
      center,
      Offset(left, bottom),
      Offset(right, top),
      Offset(right, bottom),
      Offset(left, top),
    ];
    emitter.motions.run(MotionRepeatForever(
      MotionSpline((pt) => emitter.position = pt, points, 3),
    ));
    emitter.start();
    return emitter;
  }

  Future<Node> _createLogoFirework() async {
    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/1pixel');
    emitter.counter = new ps.Blast(4000);

    final logo = _game.images[flintLogoName]!;
    final logoBitmap = await logo.toByteData();
    if (logoBitmap == null) {
      throw Exception('Cannot load logo');
    }

    emitter.addInitializer(ps.ColorInit(Color(0xFFFF3300), Color(0xFFFFFF00)));
    emitter.addInitializer(ps.Lifetime(6));
    emitter.addInitializer(ps.Position(ps.DiscZone(Point(0, 0), 10)));
    final scale = 1.0;
    emitter.addInitializer(ps.Velocity(ps.BitmapDataZone(logoBitmap, logo.width,
        logo.height, -132 * scale, -300 * scale, scale, scale)));

    emitter.addAction(ps.Age(ps.Quadratic.easeIn));
    emitter.addAction(ps.Fade(1.0, 0));
    emitter.addAction(ps.Move());
    emitter.addAction(ps.LinearDrag(0.5));
    emitter.addAction(ps.Accelerate(0, 70));

    emitter.onEmitterDone = (emitter) => emitter.start();
    emitter.position =
        Offset(spriteBox!.size.width / 2, spriteBox!.size.height / 2);
    emitter.start();
    return emitter;
  }

  Future<Node> _createRain() async {
    final bkg = _game.images[rainBkgName]!;
    final scale = spriteBox!.size.width / bkg.width;
    Node parent = Node()..scale = scale;

    parent.addChild(Sprite.fromImage(bkg));

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/1pixel');
    emitter.counter = ps.Steady(1000);

    emitter.addInitializer(ps.Position(
        ps.LineZone(Point<double>(-55, -5), Point<double>(605, -5))));
    emitter
        .addInitializer(ps.Velocity(ps.DiscZone(Point<double>(60, 400), 20)));
    emitter.addInitializer(ps.AlphaInit(0.5, 0.85));

    emitter.addAction(ps.Move());
    emitter.addAction(
        ps.CollisionZone(ps.DiscZone(Point<double>(245, 275), 150), 0.3));
    emitter.addAction(ps.DeathZone(
        ps.RectangleZone(Rect.fromLTRB(-60, -10, 600, 400)),
        invertZone: true));
    emitter.addAction(ps.Accelerate(0, 500));
    emitter.addAction(ps.SpeedLimit(500));

    emitter.start();
    emitter.runAhead(4, 30);
    parent.addChild(emitter);

    return parent;
  }

  Future<Node> _createSnowfall() async {
    final fg = _game.images[snowFgName]!;
    final bkg = _game.images[snowBkgName]!;
    final scale = spriteBox!.size.width / bkg.width;
    Node parent = Node()..scale = scale;

    parent.addChild(Sprite.fromImage(bkg));

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/radial_dot_4x4');
    emitter.counter = ps.Steady(150);

    emitter.addInitializer(
        ps.Position(ps.LineZone(Point<double>(-5, 0), Point<double>(605, 0))));
    emitter.addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 65))));
    emitter.addInitializer(ps.ScaleImageInit(0.75, 2));

    emitter.addAction(ps.Move());
    emitter.addAction(ps.DeathZone(
        ps.RectangleZone(Rect.fromLTRB(-10, -10, 600, 400)),
        invertZone: true));
    emitter.addAction(ps.RandomDrift(20, 20));

    parent.addChild(emitter);
    parent.addChild(Sprite.fromImage(fg));

    emitter.start();
    emitter.runAhead(10);

    return parent;
  }

  Future<Node> _createGravityWell() async {
    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/1pixel');
    emitter.counter = ps.Blast(6000);

    emitter.addInitializer(ps.ColorInit(Color(0xFFFF00FF), Color(0xFF00FFFF)));
    emitter
        .addInitializer(ps.Position(ps.DiscZone(Point<double>(200, 200), 200)));

    emitter.addAction(ps.Move());
    emitter.addAction(ps.GravityWell(25, 200, 200));
    emitter.addAction(ps.GravityWell(25, 75, 75));
    emitter.addAction(ps.GravityWell(25, 325, 325));
    emitter.addAction(ps.GravityWell(25, 75, 325));
    emitter.addAction(ps.GravityWell(25, 325, 75));
    emitter.start();
    return emitter;
  }

  Future<Node> _createMutualGravity() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/dot4x4');
    emitter.counter = ps.Blast(48);

    emitter.addInitializer(ps.ColorInit(Color(0xFFFF00FF), Color(0xFF00FFFF)));
    emitter.addInitializer(ps.Position(
        ps.RectangleZone(Rect.fromLTRB(10, 10, width - 20, height - 20))));

    emitter.addAction(ps.MutualGravity(10, 500, 3));
    emitter.addAction(ps.BoundingBox(0, 0, width, height));
    emitter.addAction(ps.SpeedLimit(150));
    emitter.addAction(ps.Move());
    emitter.start();
    return emitter;
  }

  Future<Node> _createFlocking() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final parent = Node()
      ..customPainter = (canvas) {
        canvas.drawRect(
            Rect.fromLTWH(0, 0, width, height),
            Paint()
              ..style = PaintingStyle.fill
              ..color = Color(0xffcccccc));
      };

    final emitter =
        ps.Emitter(_particleSpriteSheet, defaultParticleName: 'particles/bird');
    emitter.counter = ps.Blast(250);

    emitter.addInitializer(ps.Position(
        ps.RectangleZone(Rect.fromLTRB(10, 10, width - 20, height - 20))));
    emitter.addInitializer(ps.Velocity(ps.DiscZone(Point(0, 0), 150, 100)));

    emitter.addAction(ps.ApproachNeighbours(150, 100));
    emitter.addAction(ps.MatchVelocity(20, 200));
    emitter.addAction(ps.MinimumDistance(10, 600));
    emitter.addAction(ps.SpeedLimit(100, true));
    emitter.addAction(ps.RotateToDirection());
    emitter.addAction(ps.BoundingBox(0, 0, width, height));
    emitter.addAction(ps.SpeedLimit(200));
    emitter.addAction(ps.Move());
    parent.addChild(emitter);
    emitter.start();

    return parent;
  }

  Future<Node> _createLogoOnFire() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final logo = _game.images[flintLogoOrangeName]!;
    final logoBitmap = await logo.toByteData();
    if (logoBitmap == null) {
      throw Exception('Cannot load logo');
    }

    final parent = Node()
      ..position = Offset((width - logo.width.toDouble()) / 2,
          (height - logo.height.toDouble()) / 2);

    parent.addChild(Sprite.fromImage(logo));

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/fire_blob');
    emitter.counter = ps.Steady(600);

    emitter.addInitializer(ps.Lifetime(0.8));
    emitter.addInitializer(ps.Velocity(
        ps.DiscSectorZone(Point<double>(0, 0), 10.0, 5.0, -135.0, -45.0)));
    emitter.addInitializer(
        ps.Position(ps.BitmapDataZone(logoBitmap, logo.width, logo.height)));

    emitter.addAction(ps.Age(ps.TwoWay.quadratic));
    emitter.addAction(ps.Move());
    emitter.addAction(ps.LinearDrag(1));
    emitter.addAction(ps.Accelerate(0, -20));
    emitter.addAction(ps.ColorChange(Color(0xFFFF9900), Color(0x00FFDD66)));
    emitter.addAction(ps.ScaleImage(1.4, 2));
    emitter.addAction(ps.RotateToDirection());

    parent.addChild(emitter);
    emitter.start();

    return parent;
  }

  Future<Node> _createPachinko() async {
    final bkgWidth = 480.0;
    final bkgHeight = 425.0;

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/dot4x4');
    emitter.counter = ps.TimePeriod(100, 1);
    emitter.addInitializer(ps.CollisionRadiusInit(5));
    emitter.addInitializer(ps.Position(
        ps.LineZone(Point<double>(130, -5), Point<double>(350, -5))));
    emitter.addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 100), 20)));

    emitter.addAction(ps.Move());
    emitter.addAction(ps.Accelerate(0, 100));
    emitter.addAction(ps.Collide());
    emitter.addAction(ps.DeathZone(
        ps.RectangleZone(Rect.fromLTRB(0, bkgHeight, bkgWidth, 450))));
    emitter.addAction(
        ps.CollisionZone(ps.DiscZone(Point<double>(240, 205), 242), 0.5));

    final List<Offset> expPins = [];
    for (int i = 0; i < _pins.length; i++) {
      final pin = _pins[i] - Offset(10, 45);
      expPins.add(pin);
      if (pin.dx < 250) {
        expPins.add(Offset(500 - pin.dx, pin.dy));
      }
    }

    expPins.forEach((pin) => emitter
        .addAction(ps.CollisionZone(ps.PointZone(Point(pin.dx, pin.dy)), 0.5)));
    emitter.onEmitterDone = (emitter) => emitter.start();

    final parent = Node()
      ..scale = spriteBox!.size.width / bkgWidth
      ..customPainter = (canvas) {
        canvas.drawRect(
            Rect.fromLTWH(0, 0, bkgWidth, bkgHeight),
            Paint()
              ..style = PaintingStyle.fill
              ..color = Color(0xff666666));
        canvas.drawCircle(
            Offset(240, 205),
            240,
            Paint()
              ..style = PaintingStyle.fill
              ..color = Color(0xff000000));
        final pinPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Color(0xff999999);
        expPins.forEach((pin) => canvas.drawCircle(pin, 1, pinPaint));
      };

    parent.addChild(emitter);
    emitter.start();
    return parent;
  }

  Future<Node> _createSimpleFirework() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final emitter = ps.Emitter(_particleSpriteSheet)
      ..position = Offset(width / 2, height / 2);
    emitter.counter = ps.Blast(1000);

    emitter.addInitializer(ps.TexturesInit()
      ..add('particles/dot4x4', 3)
      ..add('particles/radial_dot_4x4', 3)
      ..add('particles/1pixel', 1));
    emitter.addInitializer(ps.ColorInit(Color(0xFFFFFF00), Color(0xFFFF6600)));
    emitter
        .addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 0), 200, 10)));
    emitter.addInitializer(ps.Lifetime(3, 5));

    emitter.addAction(ps.Age(ps.Quadratic.easeIn));
    emitter.addAction(ps.Move());
    emitter.addAction(ps.FadeWithTwinkle(
        minDelay: .5, maxDelay: 2, onInterval: .5, offInterval: .5));
    emitter.addAction(ps.Accelerate(0, 50));
    emitter.addAction(ps.LinearDrag(0.5));

    emitter.onEmitterDone = (emitter) => emitter.start();
    emitter.start();

    return emitter;
  }

  Future<Node> _createSimpleFireworkWithTrailEffect() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final emitter = ps.Emitter(_particleSpriteSheet)
      ..position = Offset(width / 2, height / 2)
      ..counter = ps.Blast(300)
      ..addInitializer(
        ps.TexturesInit()..add('particles/dot4x4', 3),
      )
      ..addInitializer(ps.ColorInit(Color(0xFFFFFF00), Color(0xFFFF6600)))
      ..addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 0), 200, 10)))
      ..addInitializer(ps.Lifetime(3, 5))
      ..addInitializer(ps.ScaleImageInit(0.4, 1))
      ..addAction(ps.Age(ps.Quadratic.easeIn))
      ..addAction(ps.ColorBrightness(30, 0, curve: Curves.easeInCubic))
      ..addAction(ps.Move())
      ..addAction(ps.Fade.withCurve(curve: Curves.easeInQuart))
      ..addAction(ps.Accelerate(0, 50))
      ..addAction(ps.LinearDrag(0.5));

    emitter.onEmitterDone = (emitter) => emitter.start();
    emitter.start();

    return TrailEffectNode(15)..addChild(emitter);
  }

  Future<Node> _createSimpleFireworkWithMultiColorTrailEffect() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final emitter = ps.Emitter(_particleSpriteSheet)
      ..position = Offset(width / 2, height / 2)
      ..counter = ps.Blast(300)
      ..addInitializer(
        ps.TexturesInit()..add('particles/dot4x4', 3),
      )
      ..addInitializer(ps.ColorInit(Color(0xFFFFFF00), Color(0xFFFF6600)))
      ..addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 0), 200, 10)))
      ..addInitializer(ps.Lifetime(3, 4))
      ..addInitializer(ps.ScaleImageInit(0.4, 1))
      ..addAction(ps.Age(ps.Quadratic.easeIn))
      ..addAction(ps.ColorSpinHue(360, 0, curve: Curves.easeInCubic))
      ..addAction(ps.Move())
      ..addAction(ps.Fade.withCurve(curve: Curves.easeInQuart))
      ..addAction(ps.Accelerate(0, 50))
      ..addAction(ps.LinearDrag(0.5));

    emitter.onEmitterDone = (emitter) => emitter.start();
    emitter.start();

    return TrailEffectNode(15)..addChild(emitter);
  }

  Future<Node> _createSimpleGreenFireworkWithTrailEffect() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final emitter = ps.Emitter(_particleSpriteSheet)
      ..position = Offset(width / 2, height / 2)
      ..counter = ps.Blast(150)
      ..addInitializer(
        ps.TexturesInit()..add('particles/green_glow_ball_16x16', 3),
      )
      ..addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 0), 200, 10)))
      ..addInitializer(ps.Lifetime(2, 2.5))
      ..addInitializer(ps.ScaleImageInit(0.4, 1.0))
      ..addAction(ps.Age(ps.Quadratic.easeIn))
      ..addAction(ps.Move())
      ..addAction(ps.Fade.withCurve(curve: Curves.easeInQuart))
      ..addAction(ps.Accelerate(0, 100))
      ..addAction(ps.LinearDrag(0.5));

    emitter.onEmitterDone = (emitter) => emitter.start();
    emitter.start();

    return TrailEffectNode(15)..addChild(emitter);
  }

  Future<Node> _createSimpleRedFireworkWithTrailEffect() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final emitter = ps.Emitter(_particleSpriteSheet)
      ..position = Offset(width / 2, height / 2)
      ..counter = ps.Blast(200)
      ..addInitializer(
        ps.TexturesInit()..add('particles/red_glow_ball_16x16', 3),
      )
      ..addInitializer(ps.ColorInit(Color(0xFFFFFF00), Color(0xFFFF6600)))
      ..addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 0), 200, 10)))
      ..addInitializer(ps.Lifetime(3, 5))
      ..addInitializer(ps.ScaleImageInit(0.4, 1))
      ..addAction(ps.Age(ps.Quadratic.easeIn))
      ..addAction(ps.Move())
      ..addAction(ps.Fade.withCurve(curve: Curves.easeInQuart))
      ..addAction(ps.Accelerate(0, 50))
      ..addAction(ps.LinearDrag(0.5));

    emitter.onEmitterDone = (emitter) => emitter.start();
    emitter.start();

    return TrailEffectNode(15)..addChild(emitter);
  }

  Future<Node> _createLogoMorph() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;
    final image1 = _game.images[flintLogo320x80Name]!;
    final image1Bitmap = await image1.toByteData();
    if (image1Bitmap == null) {
      throw Exception('Could not load image');
    }

    final image1Zone =
        ps.BitmapDataZone(image1Bitmap, image1.width, image1.height, 0, 0);

    final image2 = _game.images[particlesWordBlack320x80Name]!;
    final image2Bitmap = await image2.toByteData();
    if (image2Bitmap == null) {
      throw Exception('Could not load image');
    }

    final image2Zone =
        ps.BitmapDataZone(image2Bitmap, image2.width, image2.height, 0, 0);

    const particleName = 'particles/1pixel';
    final startEmitter =
        ps.Emitter(_particleSpriteSheet, defaultParticleName: particleName);
    startEmitter.counter = ps.Blast(5000);

    startEmitter
        .addInitializer(ps.ColorInit(Color(0xFFFFFF00), Color(0xFFCC6600)));
    startEmitter.addInitializer(ps.Lifetime(6));
    startEmitter.addInitializer(ps.Position(image1Zone));

    startEmitter.addAction(ps.Age(ps.Quadratic.easeInOut));
    startEmitter.addAction(ps.TweenToZone(image2Zone));

    final tween1Emitter = ps.Emitter(_particleSpriteSheet);
    tween1Emitter.addInitializer(ps.Lifetime(6));

    tween1Emitter.addAction(ps.Age(ps.Quadratic.easeInOut));
    tween1Emitter.addAction(ps.TweenToZone(image1Zone));

    final tween2Emitter = ps.Emitter(_particleSpriteSheet);
    tween2Emitter.addInitializer(ps.Lifetime(6));

    tween2Emitter.addAction(ps.Age(ps.Quadratic.easeInOut));
    tween2Emitter.addAction(ps.TweenToZone(image2Zone));

    startEmitter.onParticleDisposal = (emitter, particle) {
      particle.revive();
      tween1Emitter.addParticle(particle, true);
      if (!tween1Emitter.started) {
        tween1Emitter.start();
      }
      return false;
    };
    tween1Emitter.onParticleDisposal = (emitter, particle) {
      particle.revive();
      tween2Emitter.addParticle(particle, true);
      if (!tween2Emitter.started) {
        tween2Emitter.start();
      }
      return false;
    };
    tween2Emitter.onParticleDisposal = startEmitter.onParticleDisposal;

    final composite =
        Node(Size(image1.width.toDouble(), image2.height.toDouble()))
          ..position = Offset(width / 2, height / 2)
          ..relativePositionAnchor = Sprite.centerOffset;

    composite.addChild(startEmitter);
    composite.addChild(tween1Emitter);
    composite.addChild(tween2Emitter);

    startEmitter.start();
    tween1Emitter.start();
    tween2Emitter.start();
    return composite;
  }

  Future<Node> _createTinderBox() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;

    final planetWH = 90;
    final planetCenterX = width - (planetWH - 10);
    final planetCenterY = height * .33;

    final container = Node();

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/1pixel');
    emitter.counter = ps.Pulse(1, 200);

    emitter.addInitializer(ps.Position(
        ps.DiscZone(Point<double>(planetCenterX, planetCenterY), 41)));
    emitter.addInitializer(ps.Lifetime(4, 8));

    emitter.addAction(ps.ColorChange(Color(0xffffff00), Color(0xffdd0000)));
    emitter.addAction(ps.Age());
    emitter.addAction(ps.RandomDrift(40, 40));
    emitter.addAction(ps.Move());
    emitter.addAction(ps.LinearDrag(0.5));
    emitter.addAction(ps.GravityWell(450, width * .10, height * .98));

    emitter.start();

    container.addChild(emitter);

    // Planet is 90x90
    final planet = Sprite.fromImage(_game.images[icePlanetName]!)
      ..position =
          Offset(planetCenterX - planetWH / 2, planetCenterY - planetWH / 2);
    container.addChild(planet);

    return container;
  }

  Future<Node> _createConfetti() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/confetti1')
      ..position = Offset(width, height * .8);
    emitter.counter = ps.Blast(40);
    // Note that particle.x/y is 0/0 relative to this node.
    final pointZero = Point<double>(0, 0);
    emitter.addInitializer(ps.TexturesInit()
          ..add('particles/confetti1')
          ..add('particles/confetti2')
//      ..add('particles/confetti3')
          ..add('particles/confetti4')
          ..add('particles/confetti5')
//      ..add('particles/confetti6')
        );
    emitter.addInitializer(ps.ColorsInit()
      ..addColor(Color(0xfff71873))
      ..addColor(Color(0xfff8b54a))
      ..addColor(Color(0xffbe1e68))
      ..addColor(Color(0xffb4df86))
      ..addColor(Color(0xffc8d92b))
      ..addColor(Color(0xfffbe422))
      ..addColor(Color(0xff01a7db)));
    emitter.addInitializer(ps.Position(ps.PointZone(pointZero)));
    emitter.addInitializer(
        ps.Velocity(ps.DiscSectorZone(pointZero, 700, 300, -120, -100)));
    emitter.addInitializer(ps.RotateVelocity(0, 60));
    emitter.addInitializer(ps.ScaleImageInit(.75, 1));

    emitter.addAction(ps.DeathZone(
        ps.RectangleZone(Rect.fromLTRB(-20, -20, width + 100, height + 20)),
        invertZone: true));
    emitter.addAction(ps.RandomDrift(200, 0));
    emitter.addAction(ps.Move());
    emitter.addAction(ps.Rotate());
    emitter.addAction(ps.Accelerate(0, 150));
    emitter.addAction(ps.LinearDrag(1));

    emitter.onEmitterDone = (e) => e.start();

    emitter.start();
    return emitter;
  }

  Future<Node> _createFireAndSmoke() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;

    final container = Node()..position = Offset(width / 2, height * .95);

    final fireEmitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/fire_blob2');

    fireEmitter.counter = ps.Steady(60);

    fireEmitter.addInitializer(ps.Lifetime(2, 3));
    fireEmitter.addInitializer(
        ps.Velocity(ps.DiscSectorZone(Point<double>(0, 0), 20, 10, -180, 0)));
    fireEmitter
        .addInitializer(ps.Position(ps.DiscZone(Point<double>(0, 0), 3)));

    fireEmitter.addAction(ps.Age());
    fireEmitter.addAction(ps.Move());
    fireEmitter.addAction(ps.LinearDrag(1));
    fireEmitter.addAction(ps.Accelerate(0, -40));
    fireEmitter.addAction(ps.ColorChange(Color(0xFFFFCC00), Color(0x00CC0000)));
    fireEmitter.addAction(ps.ScaleImage(1, 1.5));
    fireEmitter.addAction(ps.RotateToDirection());
    fireEmitter.start();

    final smokeEmitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/radial_dot_64x64');
    smokeEmitter.counter = ps.Steady(10);

    smokeEmitter.addInitializer(ps.Lifetime(11, 12));
    smokeEmitter.addInitializer(ps.Velocity(
        ps.DiscSectorZone(Point<double>(0, 0), 40, 30, -102.86, -77.14)));

    smokeEmitter.addAction(ps.Age());
    smokeEmitter.addAction(ps.Move());
    smokeEmitter.addAction(ps.LinearDrag(0.01));
    // Originally (1,15) based on 6x6 dot, but ours is 64x64, so changed the scale by a factor of 6/64 (0.0938)
    smokeEmitter.addAction(ps.ScaleImage(0.0938, 1.4063));
    smokeEmitter.addAction(ps.Fade(0.15, 0));
    smokeEmitter.addAction(ps.RandomDrift(15, 15));
    smokeEmitter.start();

    container.addChild(smokeEmitter);
    container.addChild(fireEmitter);
    return container;
  }

  Future<Node> _createBrownianMotion() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/circle32x32');
    emitter.counter = ps.Blast(500);

    final air = ps.InitializerGroup([
      ps.ScaleImageInit(2 / 32), // Scale to 2x2
      ps.ColorInit(Color(0xFF666666), Color(0xFF666666)),
      ps.MassInit(1),
      ps.CollisionRadiusInit(2),
    ]);

    final smoke = ps.InitializerGroup([
      ps.ScaleImageInit(10 / 32), // Scale to 10x10
      ps.ColorInit(Color(0xFFFFFFFF), Color(0xFFFFFFFF)),
      ps.MassInit(10),
      ps.CollisionRadiusInit(10),
    ]);

    emitter.addInitializer(
        ps.Position(ps.RectangleZone(Rect.fromLTWH(0, 0, width, height))));
    emitter.addInitializer(
        ps.Velocity(ps.DiscZone(Point<double>(0, 0), 150, 100)));
    emitter.addInitializer(ps.ChooseInitializer()
      ..addInitializer(air, 30)
      ..addInitializer(smoke, 1));

    emitter.addAction(ps.Move());
    emitter.addAction(ps.Collide(1));
    emitter.addAction(ps.BoundingBox(0, 0, width, height, 1));
    emitter.start();

    return emitter;
  }

  Future<Node> _createCatherineWheel() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;

    final emitter = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/horizontal_line_12px_glow')
      ..position = Offset(width / 2, height / 2);
    emitter.counter = ps.Steady(200);

    emitter.addActivity(ps.RotateEmitter(-400));

    emitter.addInitializer(ps.ColorInit(Color(0xFFFFFF00), Color(0xFFFF6600)));
    emitter.addInitializer(ps.Velocity(
        ps.DiscSectorZone(Point<double>(0, 0), 200, 170, 0, 11.46)));
    emitter.addInitializer(ps.Lifetime(1.3));

    emitter.addAction(ps.Age(ps.Quadratic.easeIn));
    emitter.addAction(ps.Move());
    emitter.addAction(ps.Fade());
    emitter.addAction(ps.Accelerate(0, 50));
    emitter.addAction(ps.LinearDrag(0.5));

    emitter.start();

    return TrailEffectNode(10)..addChild(emitter);
  }

  Future<Node> _createChrysanthemumFirework() async {
    final width = spriteBox!.size.width;
    final height = spriteBox!.size.height;

    // TODO Other effects:
    // - Gradual color change of new particles coming from emitter (ColorChange action)

    final container = Node();
    final bloom = ps.Emitter.ofEmitters();
    bloom.counter = ps.Blast(400);

    // TODO Need an evenly disbursed zone - we can then get away with fewer on the blast.
    final maxVelocity = 1000.0;
    final maxVelocitySq = maxVelocity * maxVelocity;
    final velocityDrivenColorList = ps.WeightedList<Color>()
          ..add(Colors.redAccent, .5)
          ..add(Colors.yellowAccent, 1)
          ..add(Colors.greenAccent, 1)
          ..add(Colors.blueAccent, 1) //
        ;

    bloom.addInitializer(
        ps.Velocity(ps.DiscZone(Point<double>(0, 0), maxVelocity, 15)));
    bloom.addInitializer(ps.MassInit(.1)); // Mass affects drag
    // Must add after Velocity - we need velocity during initialization.
    bloom.addInitializer(ps.InitFn((emitter, particle) {
      // This emitter emits still particles, but because the parent emitter moves, these appear to leave a trail.
      final trail = ps.Emitter(
        _particleSpriteSheet,
        defaultParticleName: 'particles/radial_dot_4x4',
      )..position = emitter.position;

      particle.subEmitter = trail;
      trail.counter = ps.TimePeriod(30, .75 + Random().nextDouble() * .25);

      // Final effect on the trail
      trail.onCounterComplete = (_) {
//        _createStarFirework(container, e.position);
        final p = trail.createParticle();
        p.lifetime = 2;
        p.velX = particle.velX;
        p.velY = particle.velY;
      };

      final sqVelocity = Point(particle.velX, particle.velY)
          .squaredDistanceTo(const Point(0, 0));
      final ratio = min(1.0, sqVelocity / maxVelocitySq);
      final velocityDrivenColor = velocityDrivenColorList.getValue(ratio);
      trail.addInitializer(
          ps.ColorInit(velocityDrivenColor, velocityDrivenColor));
      trail.addInitializer(ps.Lifetime(1.4, 1.6));

      trail.addAction(ps.Age(ps.Quadratic.easeIn));
      trail.addAction(ps.Fade());
      // These actions are only used on the final "dot" particle that is emitted after the counter is complete.
      trail.addAction(ps.Move());
      trail.addAction(ps.Accelerate(0, 10));

      trail.start();
    }));

    bloom.addAction(ps.DeathOnSubEmitterComplete());
    bloom.addAction(ps.Move());
    bloom.addAction(ps.Accelerate(0, 70)); // Controls gravity
    bloom.addAction(ps.LinearDrag(.5)); // Controls radius (tempers velocity)

    // The inner bloom - or "pistil"
    final innerBloom = ps.Emitter(
      _particleSpriteSheet,
      defaultParticleName: 'particles/radial_dot_4x4',
    )
      ..counter = ps.Blast(1000)
      ..addInitializer(ps.ColorInit(Color(0xFFFFDF00), Color(0xFFFFD700)))
      ..addInitializer(
          ps.Velocity(ps.DiscZone(Point<double>(0, 0), maxVelocity * .75, 15)))
      ..addInitializer(ps.MassInit(.1)) // Mass affects drag
      ..addInitializer(ps.Lifetime(.8, 1))
      ..addAction(ps.Age(ps.Quadratic.easeInOut))
      ..addAction(ps.Move())
      ..addAction(ps.Accelerate(0, 0))
      ..addAction(ps.LinearDrag(.8));

    final mortar = MortarEmitter(
      _particleSpriteSheet,
      'particles/radial_dot_4x4',
      startPosition: Offset(width / 2, height),
      endPosition: Offset(width / 2, height * .4),
      duration: 1.0,
    );
    mortar.onEmitterDone = (_) {
      bloom.position = mortar.position;
      innerBloom.position = mortar.position;
      bloom.start();
      innerBloom.start();
    };

    // Repeat
    bloom.onEmitterDone =
        (e) => Timer(const Duration(seconds: 1), () => mortar.start());

    container.addChild(mortar);
    container.addChild(innerBloom);
    container.addChild(bloom);
    mortar.start();

    return container;
  }

  void _createStarFirework(Node container, Offset position) {
    if (Random().nextInt(10) != 0) {
      return;
    }

    final e = ps.Emitter(_particleSpriteSheet,
        defaultParticleName: 'particles/dot4x4')
      ..position = position
      ..counter = ps.Blast(10);

    e.addInitializer(ps.ColorInit(Colors.white, Colors.white));
    // TODO Need star/evenly disbursed zone
    e.addInitializer(ps.Velocity(ps.DiscZone(Point<double>(0, 0), 60, 60)));
    e.addInitializer(ps.Lifetime(1, 1));

    e.addAction(ps.Age(ps.Quadratic.easeIn));
    e.addAction(ps.Move());
    e.addAction(ps.Fade());
    e.addAction(ps.Accelerate(0, 50));
    e.addAction(ps.LinearDrag(0.5));
    e.onEmitterDone = (emitter) => container.removeChild(e);

    container.addChild(e);
    e.start();
  }

//  Node _createAtlasNode() {
//    final image = _game.images[fireworkParticleName];
//    final rand = Random();
//    final node = new Node()
//      ..customPainter = (canvas) {
//        final numParticles = 15000;
//        final imageRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
//        final texRects = List<Rect>(numParticles)..fillRange(0, numParticles, imageRect);
//        final transforms = List<RSTransform>(numParticles);
//        final colors = List<Color>(numParticles);
//
//        final numPerRow = 100;
//        final xSpacing = _game.usableSize.width / numPerRow;
//        final ySpacing = _game.usableSize.height / (numParticles / numPerRow);
//        double x = 0, y = 0;
//        for (int i = 0; i < numParticles; i++) {
//          transforms[i] = RSTransform.fromComponents(
//              rotation: rand.nextDouble() * pi * 2,
//              scale: rand.nextDouble(),
//              anchorX: 0.5,
//              anchorY: 0.5,
//              translateX: x,
//              translateY: y);
//          if (i != 0 && (i % numPerRow) == 0) {
//            x = 0;
//            y += ySpacing;
//          } else {
//            x += xSpacing;
//          }
//          colors[i] = Color.fromARGB(0xff, rand.nextInt(256), rand.nextInt(256), rand.nextInt(256));
//        }
//        canvas.drawAtlas(image, transforms, texRects, colors, BlendMode.modulate, null, Paint());
//      };
//    return node;
//  }

}

class GameContext {
  final BuildContext flutterContext;
  final AssetBundle bundle;
  late ImageMap images;
  late MediaQueryData mediaQuery;
  Size? usableSize;

  GameContext(this.flutterContext)
      : bundle = DefaultAssetBundle.of(flutterContext) {
    images = ImageMap(bundle);
  }
}

const List<Offset> _pins = [
  Offset(241, 81),
  Offset(222, 81),
  Offset(213, 88),
  Offset(208, 94),
  Offset(202, 100),
  Offset(198, 106),
  Offset(195, 113),
  Offset(187, 93),
  Offset(182, 98),
  Offset(178, 103),
  Offset(175, 109),
  Offset(173, 114),
  Offset(172, 120),
  Offset(171, 127),
  Offset(149, 128),
  Offset(149, 120),
  Offset(147, 113),
  Offset(145, 108),
  Offset(142, 103),
  Offset(137, 98),
  Offset(132, 94),
  Offset(127, 90),
  Offset(121, 86),
  Offset(242, 123),
  Offset(238, 127),
  Offset(234, 131),
  Offset(230, 135),
  Offset(226, 139),
  Offset(214, 151),
  Offset(132, 124),
  Offset(114, 124),
  Offset(96, 124),
  Offset(123, 140),
  Offset(105, 140),
  Offset(87, 140),
  Offset(114, 156),
  Offset(96, 156),
  Offset(78, 156),
  Offset(123, 172),
  Offset(105, 172),
  Offset(87, 172),
  Offset(69, 172),
  Offset(114, 188),
  Offset(96, 188),
  Offset(78, 188),
  Offset(60, 188),
  Offset(105, 204),
  Offset(87, 204),
  Offset(69, 204),
  Offset(96, 220),
  Offset(78, 220),
  Offset(135, 202),
  Offset(130, 206),
  Offset(126, 210),
  Offset(122, 215),
  Offset(118, 220),
  Offset(115, 226),
  Offset(113, 232),
  Offset(111, 238),
  Offset(20, 191),
  Offset(24, 193),
  Offset(28, 196),
  Offset(32, 200),
  Offset(36, 204),
  Offset(39, 208),
  Offset(42, 211),
  Offset(44, 215),
  Offset(47, 219),
  Offset(50, 224),
  Offset(52, 228),
  Offset(54, 233),
  Offset(56, 238),
  Offset(151, 202),
  Offset(157, 206),
  Offset(162, 211),
  Offset(166, 216),
  Offset(169, 221),
  Offset(172, 227),
  Offset(174, 233),
  Offset(175, 239),
  Offset(196, 169),
  Offset(232, 169),
  Offset(250, 169),
  Offset(169, 185),
  Offset(187, 185),
  Offset(205, 185),
  Offset(223, 185),
  Offset(241, 185),
  Offset(178, 201),
  Offset(196, 201),
  Offset(232, 201),
  Offset(250, 201),
  Offset(187, 217),
  Offset(241, 217),
  Offset(250, 233),
  Offset(143, 220),
  Offset(134, 236),
  Offset(152, 236),
  Offset(143, 252),
  Offset(55, 280),
  Offset(73, 280),
  Offset(91, 280),
  Offset(109, 280),
  Offset(127, 280),
  Offset(46, 296),
  Offset(64, 296),
  Offset(82, 296),
  Offset(100, 296),
  Offset(118, 296),
  Offset(136, 296),
  Offset(55, 312),
  Offset(73, 312),
  Offset(91, 312),
  Offset(109, 312),
  Offset(127, 312),
  Offset(64, 330),
  Offset(82, 330),
  Offset(100, 330),
  Offset(118, 330),
  Offset(136, 330),
  Offset(164, 314),
  Offset(164, 320),
  Offset(164, 326),
  Offset(164, 332),
  Offset(164, 338),
  Offset(164, 344),
  Offset(164, 350),
  Offset(163, 356),
  Offset(161, 362),
  Offset(158, 367),
  Offset(154, 370),
  Offset(149, 372),
  Offset(186, 314),
  Offset(208, 314),
  Offset(186, 400),
  Offset(208, 400),
  Offset(176, 414),
  Offset(218, 414),
  Offset(186, 340),
  Offset(186, 346),
  Offset(186, 352),
  Offset(186, 358),
  Offset(185, 364),
  Offset(183, 370),
  Offset(180, 375),
  Offset(176, 378),
  Offset(171, 380),
  Offset(208, 340),
  Offset(208, 346),
  Offset(208, 352),
  Offset(208, 358),
  Offset(209, 364),
  Offset(211, 370),
  Offset(214, 375),
  Offset(218, 378),
  Offset(223, 380),
  Offset(223, 264),
  Offset(241, 264),
  Offset(232, 282),
  Offset(250, 282),
  Offset(241, 298),
  Offset(232, 314),
  Offset(250, 314),
  Offset(241, 330),
  Offset(232, 346),
  Offset(250, 346),
  Offset(241, 362),
  Offset(250, 378),
];
