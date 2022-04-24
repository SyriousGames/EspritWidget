// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

late ImageMap _images;
late SpriteSheet _sprites;

class FitnessDemo extends StatelessWidget {
  FitnessDemo({Key? key}) : super(key: key);

  static const String routeName = '/fitness';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Fitness')), body: _FitnessDemoContents());
  }
}

class _FitnessDemoContents extends StatefulWidget {
  _FitnessDemoContents({Key? key}) : super(key: key);

  @override
  _FitnessDemoContentsState createState() => _FitnessDemoContentsState();
}

class _FitnessDemoContentsState extends State<_FitnessDemoContents> {
  Future<Null> _loadAssets(AssetBundle bundle) async {
    _images = ImageMap(rootBundle);
    await _images.load(<String>[
      'assets/jumpingjack.png',
    ]);

    String json = await DefaultAssetBundle.of(context)
        .loadString('assets/jumpingjack.json');
    _sprites = SpriteSheet(_images['assets/jumpingjack.png']!, json);
  }

  @override
  void initState() {
    super.initState();

    //AssetBundle bundle = DefaultAssetBundle.of(context);
    _loadAssets(rootBundle).then((_) {
      setState(() {
        _assetsLoaded = true;
        workoutAnimation = _WorkoutAnimationNode(onPerformedJumpingJack: () {
          setState(() {
            _count += 1;
          });
        }, onSecondPassed: (int? seconds) {
          setState(() {
            _time = seconds ?? 0;
          });
        });
      });
    });
  }

  bool _assetsLoaded = false;
  int _count = 0;
  int _time = 0;
  int get kcal => (_count * 0.2).toInt();

  late _WorkoutAnimationNode workoutAnimation;

  @override
  Widget build(BuildContext context) {
    if (!_assetsLoaded) return Container();

    Color? buttonColor;
    String buttonText;
    VoidCallback onButtonPressed;

    if (workoutAnimation.workingOut) {
      buttonColor = Colors.red[500];
      buttonText = "STOP WORKOUT";
      onButtonPressed = endWorkout;
    } else {
      buttonColor = Theme.of(context).primaryColor;
      buttonText = "START WORKOUT";
      onButtonPressed = startWorkout;
    }

    return Material(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
      Flexible(
          child: Container(
              decoration: BoxDecoration(color: Colors.grey[800]),
              child: SpriteWidget(
                  workoutAnimation, SpriteBoxTransformMode.scaleToFit))),
      Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text('JUMPING JACKS',
              style: Theme.of(context).textTheme.headline6)),
      Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _createInfoPanelCell(Icons.accessibility, '$_count', 'COUNT'),
                _createInfoPanelCell(
                    Icons.timer, _formatSeconds(_time), 'TIME'),
                _createInfoPanelCell(Icons.flash_on, '$kcal', 'KCAL')
              ])),
      Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
              width: 300.0,
              height: 72.0,
              child: RaisedButton(
                  onPressed: onButtonPressed,
                  color: buttonColor,
                  child: Text(buttonText,
                      style: TextStyle(color: Colors.white, fontSize: 20.0)))))
    ]));
  }

  Widget _createInfoPanelCell(IconData icon, String value, String description) {
    Color color;
    if (workoutAnimation.workingOut)
      color = Colors.black87;
    else
      color = Theme.of(context).disabledColor;

    return Container(
        width: 100.0,
        child: Center(
            child: Column(children: <Widget>[
          Icon(icon, size: 48.0, color: color),
          Text(value, style: TextStyle(fontSize: 24.0, color: color)),
          Text(description, style: TextStyle(color: color))
        ])));
  }

  String _formatSeconds(int seconds) {
    int minutes = seconds ~/ 60;
    String secondsStr = "${seconds % 60}".padLeft(2, "0");
    return "$minutes:$secondsStr";
  }

  void startWorkout() {
    setState(() {
      _count = 0;
      _time = 0;
      workoutAnimation.start();
    });
  }

  void endWorkout() {
    setState(() {
      workoutAnimation.stop();

      if (_count >= 3) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Stack(children: <Widget>[
              _Fireworks(),
              AlertDialog(
                title: Text('Awesome workout'),
                content: Text(
                    'You have completed $_count jumping jacks. Good going!'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('SWEET'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ),
            ]);
          },
        );
      }
    });
  }
}

typedef void _SecondPassedCallback(int? seconds);

class _WorkoutAnimationNode extends Node {
  _WorkoutAnimationNode({this.onPerformedJumpingJack, this.onSecondPassed}) {
    size = const Size(1024.0, 1024.0);
    reset();

    _progress = _ProgressCircle(const Size(800.0, 800.0));
    _progress.relativePositionAnchor = const Offset(0.5, 0.5);
    _progress.position = const Offset(512.0, 512.0);
    addChild(_progress);

    _jumpingJack = _JumpingJack(() {
      onPerformedJumpingJack!();
    });
    _jumpingJack.scale = 0.5;
    _jumpingJack.position = const Offset(512.0, 550.0);
    addChild(_jumpingJack);
  }

  final VoidCallback? onPerformedJumpingJack;
  final _SecondPassedCallback? onSecondPassed;

  int? seconds;

  late bool workingOut;

  static const int _kTargetMillis = 1000 * 30;
  late int _startTimeMillis;
  late _ProgressCircle _progress;
  late _JumpingJack _jumpingJack;

  void reset() {
    seconds = 0;
    workingOut = false;
  }

  void start() {
    reset();
    _startTimeMillis = DateTime.now().millisecondsSinceEpoch;
    workingOut = true;
    _jumpingJack.animateJumping();
  }

  void stop() {
    workingOut = false;
    _jumpingJack.neutralPose();
  }

  @override
  void update(double dt) {
    if (workingOut) {
      int millis = DateTime.now().millisecondsSinceEpoch - _startTimeMillis;
      int newSeconds = (millis) ~/ 1000;
      if (newSeconds != seconds) {
        seconds = newSeconds;
        onSecondPassed!(seconds);
      }

      _progress.value = millis / _kTargetMillis;
    } else {
      _progress.value = 0.0;
    }
  }
}

class _ProgressCircle extends Node {
  _ProgressCircle(Size size, [this.value = 0.0]) {
    this.size = size;
  }

  static const double _kTwoPI = math.pi * 2.0;
  static const double _kEpsilon = .0000001;
  static const double _kSweep = _kTwoPI - _kEpsilon;

  double value;

  @override
  void paint(Canvas canvas) {
    Paint circlePaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 24.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2.0, size.height / 2.0),
        size.width / 2.0, circlePaint);

    Paint pathPaint = Paint()
      ..color = Colors.purple[500]!
      ..strokeWidth = 25.0
      ..style = PaintingStyle.stroke;

    double angle = value.clamp(0.0, 1.0) * _kSweep;
    Path path = Path()..arcTo(Offset.zero & size, -math.pi / 2.0, angle, false);
    canvas.drawPath(path, pathPaint);
  }
}

class _JumpingJack extends Node {
  _JumpingJack(VoidCallback onPerformedJumpingJack) {
    left = _JumpingJackSide(false, onPerformedJumpingJack);
    right = _JumpingJackSide(true, null);
    addChild(left);
    addChild(right);
  }

  void animateJumping() {
    left.animateJumping();
    right.animateJumping();
  }

  void neutralPose() {
    left.neutralPosition(true);
    right.neutralPosition(true);
  }

  late _JumpingJackSide left;
  late _JumpingJackSide right;
}

class _JumpingJackSide extends Node {
  _JumpingJackSide(bool right, this.onPerformedJumpingJack) {
    // Torso and head
    torso = _createPart('torso.png', const Offset(512.0, 512.0));
    addChild(torso);

    head = _createPart('head.png', const Offset(512.0, 160.0));
    torso.addChild(head);

    if (right) {
      torso.opacity = 0.0;
      head.opacity = 0.0;
      torso.scaleX = -1.0;
    }

    // Left side movable parts
    upperArm = _createPart('upper-arm.png', const Offset(445.0, 220.0));
    torso.addChild(upperArm!);
    lowerArm = _createPart('lower-arm.png', const Offset(306.0, 200.0));
    upperArm!.addChild(lowerArm!);
    hand = _createPart('hand.png', const Offset(215.0, 127.0));
    lowerArm!.addChild(hand!);
    upperLeg = _createPart('upper-leg.png', const Offset(467.0, 492.0));
    torso.addChild(upperLeg!);
    lowerLeg = _createPart('lower-leg.png', const Offset(404.0, 660.0));
    upperLeg!.addChild(lowerLeg!);
    foot = _createPart('foot.png', const Offset(380.0, 835.0));
    lowerLeg!.addChild(foot!);

    torso.setPivotAndPosition(Offset.zero);

    neutralPosition(false);
  }

  late _JumpingJackPart torso;
  late _JumpingJackPart head;
  _JumpingJackPart? upperArm;
  _JumpingJackPart? lowerArm;
  _JumpingJackPart? hand;
  _JumpingJackPart? lowerLeg;
  _JumpingJackPart? upperLeg;
  _JumpingJackPart? foot;

  final VoidCallback? onPerformedJumpingJack;

  _JumpingJackPart _createPart(String textureName, Offset pivotPosition) {
    return _JumpingJackPart(_sprites[textureName], pivotPosition,
        name: textureName);
  }

  void animateJumping() {
    motions.stopAll();
    motions.run(MotionSequence(<Motion>[
      _createPoseAction(null, 0, 0.5),
      MotionCallFunction(_animateJumpingLoop)
    ]));
  }

  void _animateJumpingLoop() {
    motions.run(MotionRepeatForever(MotionSequence(<Motion>[
      _createPoseAction(0, 1, 0.30),
      _createPoseAction(1, 2, 0.30),
      _createPoseAction(2, 1, 0.30),
      _createPoseAction(1, 0, 0.30),
      MotionCallFunction(() {
        if (onPerformedJumpingJack != null) onPerformedJumpingJack!();
      })
    ])));
  }

  void neutralPosition(bool animate) {
    motions.stopAll();
    if (animate) {
      motions.run(_createPoseAction(null, 1, 0.5));
    } else {
      List<double> d = _dataForPose(1);
      upperArm!.rotation = d[0];
      lowerArm!.rotation = d[1];
      hand!.rotation = d[2];
      upperLeg!.rotation = d[3];
      lowerLeg!.rotation = d[4];
      foot!.rotation = d[5];
      torso.position = Offset(0.0, d[6]);
    }
  }

  MotionInterval _createPoseAction(
      int? startPose, int endPose, double duration) {
    List<double> d0 = _dataForPose(startPose);
    List<double> d1 = _dataForPose(endPose);

    List<MotionTween> tweens = <MotionTween>[
      _tweenRotation(upperArm, d0[0], d1[0], duration),
      _tweenRotation(lowerArm, d0[1], d1[1], duration),
      _tweenRotation(hand, d0[2], d1[2], duration),
      _tweenRotation(upperLeg, d0[3], d1[3], duration),
      _tweenRotation(lowerLeg, d0[4], d1[4], duration),
      _tweenRotation(foot, d0[5], d1[5], duration),
      MotionTween<Offset>((a) => torso.position = a, Offset(0.0, d0[6]),
          Offset(0.0, d1[6]), duration)
    ];

    return MotionGroup(tweens);
  }

  MotionTween _tweenRotation(
      _JumpingJackPart? part, double r0, double r1, double duration) {
    return MotionTween((a) => part!.rotation = a, r0, r1, duration);
  }

  List<double> _dataForPose(int? pose) {
    if (pose == null) return _dataForCurrentPose();

    if (pose == 0) {
      return <double>[
        -80.0, // Upper arm rotation
        -30.0, // Lower arm rotation
        -10.0, // Hand rotation
        -15.0, // Upper leg rotation
        5.0, // Lower leg rotation
        15.0, // Foot rotation
        0.0 // Torso y offset
      ];
    } else if (pose == 1) {
      return <double>[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -70.0];
    } else {
      return <double>[40.0, 30.0, 10.0, 20.0, -20.0, 15.0, 40.0];
    }
  }

  List<double> _dataForCurrentPose() {
    return <double>[
      upperArm!.rotation,
      lowerArm!.rotation,
      hand!.rotation,
      upperLeg!.rotation,
      lowerLeg!.rotation,
      foot!.rotation,
      torso.position.dy
    ];
  }
}

class _JumpingJackPart extends Sprite {
  String name;

  _JumpingJackPart(SpriteTexture? texture, this.pivotPosition, {this.name: ''})
      : super(texture);
  final Offset pivotPosition;

  void setPivotAndPosition(Offset newPosition) {
    relativePositionAnchor =
        Offset(pivotPosition.dx / 1024.0, pivotPosition.dy / 1024.0);
    scalePivot = rotationPivot = relativePositionAnchor;
    position = newPosition;

    for (Node child in children) {
      _JumpingJackPart subPart = child as _JumpingJackPart;
      subPart.setPivotAndPosition(Offset(
          subPart.pivotPosition.dx - relativePositionAnchor.dx,
          subPart.pivotPosition.dy - relativePositionAnchor.dy));
      /*subPart.setPivotAndPosition(
            Offset(subPart.pivotPosition.dx, subPart.pivotPosition.dy));*/
    }
  }
}

class _Fireworks extends StatefulWidget {
  _Fireworks({Key? key}) : super(key: key);

  @override
  _FireworksState createState() => _FireworksState();
}

class _FireworksState extends State<_Fireworks> {
  @override
  void initState() {
    super.initState();
    fireworks = _FireworksNode();
  }

  late _FireworksNode fireworks;

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(fireworks);
  }
}

class _FireworksNode extends Node {
  _FireworksNode() {
    size = const Size(1024.0, 1024.0);
  }

  double _countDown = 0.0;

  @override
  void update(double dt) {
    if (_countDown <= 0.0) {
      _addExplosion();
      _countDown = randomDouble();
    }

    _countDown -= dt;
  }

  Color? _randomExplosionColor() {
    double rand = randomDouble();
    if (rand < 0.25)
      return Colors.pink[200];
    else if (rand < 0.5)
      return Colors.lightBlue[200];
    else if (rand < 0.75)
      return Colors.purple[200];
    else
      return Colors.cyan[200];
  }

  void _addExplosion() {
    Color startColor = _randomExplosionColor()!;
    Color endColor = startColor.withAlpha(0);

    ParticleSystem system = ParticleSystem(_sprites['particle-0.png'],
        numParticlesToEmit: 100,
        emissionRate: 1000.0,
        rotateToMovement: true,
        startRotation: 90.0,
        endRotation: 90.0,
        speed: 100.0,
        speedVar: 50.0,
        startSize: 1.0,
        startSizeVar: 0.5,
        gravity: const Offset(0.0, 30.0),
        colorSequence:
            ColorSequence.fromStartAndEndColor(startColor, endColor));
    system.position = Offset(randomDouble() * 1024.0, randomDouble() * 1024.0);
    addChild(system);
  }
}

void main() {
  runApp(MaterialApp(title: 'Fitness', home: FitnessDemo()));
}
