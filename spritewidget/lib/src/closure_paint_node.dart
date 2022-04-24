import 'dart:ui';

import 'node.dart';

/// A node which delegates painting to the given closure.
class ClosurePaintNode extends Node {
  void Function(Canvas canvas) paintClosure;

  /// Construct a [ClosurePaintNode] node which delegates painting to [paintClosure].
  ClosurePaintNode(this.paintClosure, {Size size = Size.zero}) : super(size);

  @override
  void paint(Canvas canvas) => paintClosure(canvas);
}
