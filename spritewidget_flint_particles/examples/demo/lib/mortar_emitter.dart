import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:spritewidget_flint_particles/flint_particles.dart';

class MortarEmitter extends Emitter {
  Offset startPosition;
  Offset endPosition;
  double duration = 1.0;

  MortarEmitter(SpriteSheet spriteSheet, String particleName,
      {required this.startPosition, required this.endPosition, this.duration = 1.0, int numParticles = 500})
      : super(spriteSheet, defaultParticleName: particleName) {
    this
      ..counter = TimePeriod(numParticles, duration)
      ..addInitializer(Lifetime(.25, .5))
      ..addInitializer(Velocity(DiscSectorZone(Point(0.0, 0.0), 35, 20, 89, 91)))
      ..addAction(Age(Quadratic.easeIn))
      ..addAction(Move())
      ..addAction(Fade());
  }

  @override
  void start() {
    position = startPosition;
    // TODO Emitter could twist by following a path, or curve to left or right, etc.
    final points = [
      startPosition,
      endPosition,
    ];
    motions.run(
      MotionSpline((pt) => position = pt, points, duration, Curves.easeInCubic),
    );

    super.start();
  }
}
