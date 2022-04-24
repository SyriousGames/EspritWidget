// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flare_flutter/flare.dart';
// import 'package:flare_flutter/flare_actor.dart';
// import 'package:flutter/services.dart';
//
// import 'debug_canvas.dart';
// import 'node.dart';

/// Displays a Flare Animation (https://www.2dimensions.com/).
///
/// Based on Flame Engine's implementation (https://github.com/flame-engine/flame
/// flare_animation.dart).
/// TODO This is currently broken with Flare/Rive 1. It needs to be ported to Rive 2 https://github.com/rive-app/rive-flutter
// class FlareAnimationNode extends Node {
//   final FlutterActorArtboard artboard;
//
//   String _animationName;
//   final List<FlareAnimationLayer> _animationLayers = [];
//   Picture _picture;
//   bool debug = false;
//
//   FlareAnimationNode(this.artboard, [Size size = null]) {
//     this.size = size ?? Size(artboard.width, artboard.height);
//   }
//
//   static Future<FlareAnimationNode> load(String fileName, AssetBundle bundle,
//       {Size size = null, bool antialias}) async {
//     final actor = FlutterActor();
//     await actor.loadFromBundle(bundle, fileName);
//     await actor.loadImages();
//
//     final artboard = actor.artboard.makeInstance();
//     artboard.makeInstance();
//     artboard.initializeGraphics();
//     // In 2.0.6+:
//     if (antialias != null) {
//       (artboard as FlutterActorArtboard).antialias = antialias;
//     }
//     artboard.advance(0.0);
//
//     return FlareAnimationNode(artboard, size);
//   }
//
//   void updateAnimation(String animation) {
//     _animationName = animation;
//
//     if (_animationName != null && artboard != null) {
//       _animationLayers.clear();
//
//       ActorAnimation animation = artboard.getAnimation(_animationName);
//       if (animation != null) {
//         _animationLayers.add(FlareAnimationLayer()
//           ..name = _animationName
//           ..animation = animation
//           ..mix = 1.0
//           ..mixSeconds = 0.2);
//         animation.apply(0.0, artboard, 1.0);
//         artboard.advance(0.0);
//       }
//     }
//   }
//
//   @override
//   void paint(Canvas canvas) {
//     if (_picture == null) {
//       return;
//     }
//
//     canvas.drawPicture(_picture);
//   }
//
//   @override
//   void update(double dt) {
//     int lastFullyMixed = -1;
//     double lastMix = 0.0;
//
//     List<FlareAnimationLayer> completed = [];
//
//     for (int i = 0; i < _animationLayers.length; i++) {
//       FlareAnimationLayer layer = _animationLayers[i];
//       layer.mix += dt;
//       layer.time += dt;
//
//       lastMix = (layer.mixSeconds == null || layer.mixSeconds == 0.0)
//           ? 1.0
//           : min(1.0, layer.mix / layer.mixSeconds);
//       if (layer.animation.isLooping) {
//         layer.time %= layer.animation.duration;
//       }
//
//       layer.animation.apply(layer.time, artboard, lastMix);
//       if (lastMix == 1.0) {
//         lastFullyMixed = i;
//       }
//
//       if (layer.time > layer.animation.duration) {
//         completed.add(layer);
//       }
//     }
//
//     if (lastFullyMixed != -1) {
//       _animationLayers.removeRange(0, lastFullyMixed);
//     }
//
//     if (_animationName == null &&
//         _animationLayers.length == 1 &&
//         lastMix == 1.0) {
//       // Remove remaining animations.
//       _animationLayers.removeAt(0);
//     }
//
//     if (artboard != null) {
//       artboard.advance(dt);
//     }
//
//     // Memory render frame
//     final r = PictureRecorder();
//     var c = Canvas(r);
//     if (debug) {
//       c = DebugCanvas(c);
//     }
//
//     final double xScale = size.width / artboard.width;
//     final double yScale = size.height / artboard.height;
//
//     c.scale(xScale, yScale);
//     artboard.draw(c);
//
//     _picture = r.endRecording();
//     if (debug) {
//       (c as DebugCanvas).printSummary();
//     }
//   }
// }
