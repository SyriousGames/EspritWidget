import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';

import 'layer.dart';
import 'motion.dart';
import 'node.dart';
import 'sprite_box.dart';

typedef EventCallback = void Function(SpriteBoxEvent event);

/// A node that implements basic button functionality.
///
/// The button's rendering is comprised of its children.
class ButtonNode extends Layer {
  EventCallback? onTriggered;
  EventCallback? onArmed;
  EventCallback? onDisarmed;
  bool _armed = false;

  /// Creates a [ButtonNode].
  ///
  /// [onTriggered] is called when the button is triggered (e.g., tapped, clicked, keyboard trigger) by the user.
  /// [onArmed] is called when the button is ready to be triggered (e.g., the user has pressed down, but not released).
  /// [size] is the size of the button. Required in order to receive events.
  ButtonNode(
      {this.onTriggered, this.onArmed, this.onDisarmed, Size size = Size.zero})
      : super(size: size) {
    userInteractionEnabled = true;
  }

  /// [true] if the button is enabled. If the button is disabled, it cannot be armed or triggered.
  bool enabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (enabled && spriteBox != null) {
      var pointInNodeSpace = convertPointToNodeSpace(event.boxPosition);
      final isInside = isPointInside(pointInNodeSpace);
      if (event.type is PointerDownEvent) {
        if (!_armed) {
          _armed = true;
          _onArmed(event);
          return true;
        }
      } else if (event.type is PointerMoveEvent) {
        if (_armed && !isInside) {
          _armed = false;
          _onDisarmed(event);
        }
      } else if (event.type is PointerUpEvent) {
        if (_armed) {
          _armed = false;
          _onTriggered(event);
          return true;
        }
      }
    }

    return false;
  }

  void _onArmed(event) {
    if (onArmed != null) {
      onArmed!(event);
    }
  }

  void _onDisarmed(event) {
    if (onDisarmed != null) {
      onDisarmed!(event);
    }
  }

  void _onTriggered(event) {
    if (onTriggered != null) {
      onTriggered!(event);
    }
  }
}

/// A button that provides arm/disarm effects.
class ButtonWithPressEffects extends ButtonNode {
  /// Creates a [ButtonWithPressEffects].
  ///
  /// [onTriggered] is called when the button is triggered (e.g., tapped, clicked, keyboard trigger) by the user.
  /// [onArmed] is called when the button is ready to be triggered (e.g., the user has pressed down, but not released).
  /// [size] is the size of the button. Required in order to receive events.
  ButtonWithPressEffects(
      {EventCallback? onTriggered,
      EventCallback? onArmed,
      EventCallback? onDisarmed,
      Size size = Size.zero})
      : super(
            onTriggered: onTriggered,
            onArmed: onArmed,
            onDisarmed: onDisarmed,
            size: size) {
    rotationPivot = scalePivot = const Offset(.5, .5);
  }

  @override
  void _onArmed(event) {
    _runScaleEffect(1.0, 0.9, 0.05, Curves.bounceOut);
    super._onArmed(event);
  }

  @override
  void _onDisarmed(event) {
    _runScaleEffect(0.9, 1.0, 0.05, Curves.linear);
    super._onDisarmed(event);
  }

  @override
  void _onTriggered(event) {
    _runScaleEffect(0.9, 1.0, 0.1, Curves.bounceOut);
    super._onTriggered(event);
  }

  void _runScaleEffect(double start, double end, double time, Curve curve) {
    motions.run(MotionTween<double>((v) => scale = v, start, end, time, curve));
  }
}

/// A more sophisticated and opinionated button which provides arm/disarm effects and disabled rendering.
///
/// The label is automatically centered with the background.
class ButtonWithBackgroundAndLabel extends ButtonWithPressEffects {
  ButtonWithBackgroundAndLabel({
    required this.background,
    required this.label,
    EventCallback? onTriggered,
    EventCallback? onArmed,
    EventCallback? onDisarmed,
  }) : super(
            onTriggered: onTriggered,
            onArmed: onArmed,
            onDisarmed: onDisarmed,
            size: background.size) {
    addChild(background);
    addChild(label);
  }

  Node background;
  Node label;

  void set enabled(bool enabled) {
    super.enabled = enabled;
    colorOverlay = enabled ? null : const Color.fromRGBO(128, 128, 128, 0.75);
  }
}
