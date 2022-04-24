// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

import 'constraint.dart';
import 'motion.dart';
import 'sprite_box.dart';

/// Converts degrees to radians.
double convertDegrees2Radians(double degrees) => degrees * math.pi / 180.0;

/// Converts radians to degrees.
double convertRadians2Degrees(double radians) => radians * 180.0 / math.pi;

/// A base class for all objects that can be added to the sprite node tree and rendered to screen using [SpriteBox] and
/// [SpriteWidget].
///
/// The [Node] class itself doesn't render any content, but provides the basic functions of any type of node, such as
/// handling transformations and user input. To render the node tree, a root node must be added to a [SpriteBox] or a
/// [SpriteWidget]. Commonly used sub-classes of [Node] are [Sprite] and [Label].
///
/// Nodes form a hierarchical tree. Each node can have a number of children, and the transformation (positioning,
/// rotation, and scaling) of a node also affects its children.
class Node {
  // Constructors

  /// Creates a new [Node] without any transformation.
  Node([Size size = Size.zero]) {
    this.size = size;
  }

  // Member variables

  SpriteBox? _spriteBox;
  Node? _parent;

  Offset _position = Offset.zero;
  double _rotation = 0.0;
  Offset? _rotationPivotPixels = null;

  Matrix4? _transformMatrix = Matrix4.identity();
  Matrix4? _transformMatrixInverse;
  Matrix4? _transformMatrixNodeToBox;
  Matrix4? _transformMatrixBoxToNode;

  double _scaleX = 1.0;
  double _scaleY = 1.0;
  Offset? _scalePivotPixels = null;

  double _skewX = 0.0;
  double _skewY = 0.0;

  /// The visibility of this node and its children.
  bool visible = true;

  double _zPosition = 0.0;
  late int _addedOrder;
  int _childrenLastAddedOrder = 0;
  bool _childrenNeedSorting = false;

  /// Decides if the node and its children is currently paused.
  ///
  /// A paused node will not receive any input events, update calls, or run any animations.
  ///
  ///     myNodeTree.paused = true;
  bool paused = false;

  bool _userInteractionEnabled = false;

  /// Optional handler to handle [SpriteBoxEvent]s - in [userInteractionEnabled] is true.
  ///
  /// Eliminates the need to subclass.
  bool Function(SpriteBoxEvent event)? eventHandler;

  /// If set to true the node will receive multiple pointers, otherwise it will only receive events the first pointer.
  ///
  /// This property is only meaningful if [userInteractionEnabled] is set to true. Default value is false.
  ///
  ///     class MyCustomNode extends Node {
  ///       handleMultiplePointers = true;
  ///     }
  bool handleMultiplePointers = false;
  int? handlingPointer;

  List<Node> _children = <Node>[];

  MotionController? motionController;

  /// A tag which can be used to identify this node in the tree. It can also be
  /// used with [[removeChildrenWithTag()]] to remove all children with the
  /// given tag.
  String? tag;

  /// The [MotionController] associated with this node.
  ///
  ///     myNode.motions.run(myMotion);
  MotionController get motions {
    if (motionController == null) {
      motionController = MotionController();
      // Nulling the SpriteBox.motionControllers causes them to be rebuilt when
      // actions are run
      if (_spriteBox != null) _spriteBox!.motionControllers = null;
    }
    return motionController!;
  }

  List<Constraint>? _constraints;

  /// A [List] of [Constraint]s that will be applied to the node.
  /// The constraints are applied after the [update] method has been called.
  List<Constraint>? get constraints {
    return _constraints;
  }

  set constraints(List<Constraint>? constraints) {
    _constraints = constraints;
    // Nulling the SpriteBox.constrainedNodes causes them to be rebuilt when
    // constraints are run
    if (_spriteBox != null) _spriteBox!.constrainedNodes = null;
  }

  bool get isConstrained {
    return _constraints != null && _constraints!.length > 0;
  }

  /// Called to apply the [constraints] to the node. Normally, this method is
  /// called automatically by the [SpriteBox], but it can be called manually
  /// if the constraints need to be applied immediately.
  void applyConstraints(double dt) {
    if (_constraints == null) return;

    for (Constraint constraint in _constraints!) {
      constraint.constrain(this, dt);
    }
  }

  // Property setters and getters

  /// The [SpriteBox] this node is added to, or null if it's not currently added to a [SpriteBox].
  ///
  /// For most applications it's not necessary to access the [SpriteBox] directly.
  SpriteBox? get spriteBox => _spriteBox;

  /// The parent of this node, or null if it doesn't have a parent.
  ///
  ///     // Hide the parent
  ///     myNode.parent.visible = false;
  Node? get parent => _parent;

  /// The rotation of this node in degrees.
  ///
  ///     myNode.rotation = 45.0;
  double get rotation => _rotation;

  set rotation(double rotation) {
    _rotation = rotation;
    invalidateTransformMatrix();
  }

  /// The pivot point for rotation in pixels relative to the parent, may be null to use the default pivot.
  Offset? get rotationPivotPixels => _rotationPivotPixels;
  set rotationPivotPixels(pivot) {
    _rotationPivotPixels = pivot;
    invalidateTransformMatrix();
  }

  /// The position of this node relative to its parent.
  ///
  ///     myNode.position =  Point(42.0, 42.0);
  Offset get position => _position;

  set position(Offset position) {
    _position = position;
    invalidateTransformMatrix();
  }

  /// The skew along the x-axis of this node in degrees.
  ///
  ///     myNode.skewX = 45.0;
  double get skewX => _skewX;

  set skewX(double skewX) {
    _skewX = skewX;
    invalidateTransformMatrix();
  }

  /// The skew along the y-axis of this node in degrees.
  ///
  ///     myNode.skewY = 45.0;
  double get skewY => _skewY;

  set skewY(double skewY) {
    _skewY = skewY;
    invalidateTransformMatrix();
  }

  /// The draw order of this node compared to its parent and its siblings.
  ///
  /// By default nodes are drawn in the order that they have been added to a parent. To override this behavior the
  /// [zPosition] property can be used. A higher value of this property will force the node to be drawn in front of
  /// siblings that have a lower value. If a negative value is used the node will be drawn behind its parent.
  ///
  ///     nodeInFront.zPosition = 1.0;
  ///     nodeBehind.zPosition = -1.0;
  double get zPosition => _zPosition;

  set zPosition(double zPosition) {
    _zPosition = zPosition;
    if (_parent != null) {
      _parent!._childrenNeedSorting = true;
    }
  }

  /// The scale of this node relative its parent.
  ///
  /// The [scale] property is only valid if [scaleX] and [scaleY] are equal values.
  ///
  ///     myNode.scale = 5.0;
  double get scale {
    assert(_scaleX == _scaleY);
    return _scaleX;
  }

  set scale(double scale) {
    _scaleX = _scaleY = scale;
    invalidateTransformMatrix();
  }

  /// The horizontal scale of this node relative its parent.
  ///
  ///     myNode.scaleX = 5.0;
  double get scaleX => _scaleX;

  set scaleX(double scaleX) {
    _scaleX = scaleX;
    invalidateTransformMatrix();
  }

  /// The vertical scale of this node relative its parent.
  ///
  ///     myNode.scaleY = 5.0;
  double get scaleY => _scaleY;

  set scaleY(double scaleY) {
    _scaleY = scaleY;
    invalidateTransformMatrix();
  }

  /// The pivot point for scaling in pixels relative to the parent, may be null to use the default pivot.
  Offset? get scalePivotPixels => _scalePivotPixels;
  void set scalePivotPixels(Offset? pivot) {
    _scalePivotPixels = pivot;
    invalidateTransformMatrix();
  }

  /// Offsets the [position] relative to the [[size]]. Each component represents a fraction of this node's size
  /// (e.g., 0..1.0). For example, if a value of (0, 0) is used, positions the node relative to its top level
  /// corner. A value of (0.5, 0.5) positions based on node's center.
  Offset get relativePositionAnchor => _relativePositionAnchor;
  Offset _relativePositionAnchor = Offset.zero;
  void set relativePositionAnchor(Offset relativePosition) {
    _relativePositionAnchor = relativePosition;
    invalidateTransformMatrix();
  }

  /// Changing the size will affect the size of the rendering of the node.
  ///
  ///     myNode.size =   Size(1024.0, 1024.0);
  Size get size => _size;
  Size _size = Size.zero;
  void set size(Size? size) {
    _size = size ?? Size.zero;
    _recalcPivots();
  }

  /// The pivot point for scaling relative to the size. Each component represents a fraction of this node's size
  /// (e.g., 0..1.0).
  /// May be null to use the default pivot.
  Offset? get scalePivot => _scalePivot;
  Offset? _scalePivot;
  void set scalePivot(Offset? pivot) {
    _scalePivot = pivot;
    _recalcPivots();
  }

  /// The pivot point for rotation relative to the size. Each component represents a fraction of this node's size
  /// (e.g., 0..1.0).
  /// May be null to use the default pivot.
  Offset? get rotationPivot => _rotationPivot;
  Offset? _rotationPivot;
  void set rotationPivot(Offset? pivot) {
    _rotationPivot = pivot;
    _recalcPivots();
  }

  void _recalcPivots() {
    if (_scalePivot != null) {
      scalePivotPixels = _calcPivotPixels(_scalePivot!);
    }
    if (_rotationPivot != null) {
      rotationPivotPixels = _calcPivotPixels(_rotationPivot!);
    }
  }

  Offset _calcPivotPixels(Offset pivot) {
    double pivotX = pivot.dx;
    double pivotY = pivot.dy;
    if (pivotX >= 0.0 && pivotX <= 1.0) {
      pivotX = size.width * pivotX;
    }
    if (pivotY >= 0.0 && pivotY <= 1.0) {
      pivotY = size.height * pivotY;
    }

    return Offset(pivotX, pivotY);
  }

  /// A list of the children of this node.
  ///
  /// This list should only be modified by using the [addChild] and [removeChild] methods.
  ///
  ///     // Iterate over a nodes children
  ///     for (Node child in myNode.children) {
  ///       // Do something with the child
  ///     }
  List<Node> get children {
    _sortChildren();
    return _children;
  }

  bool _assertNonCircularAssignment(Node child) {
    Node node = this;
    while (node.parent != null) {
      node = node.parent!;
      assert(node != child); // indicates we are about to create a cycle
    }
    return true;
  }

  // Adding and removing children

  /// Remove the [_spriteBox] reference on this node and all of its children.
  void removeSpriteBoxReference() {
    _spriteBox = null;
    for (Node child in _children) {
      child.removeSpriteBoxReference();
    }
  }

  /// Sets the [_spriteBox] reference on this node and all of its children to [spriteBox].
  void addSpriteBoxReference(SpriteBox? spriteBox) {
    _spriteBox = spriteBox;
    for (Node child in _children) {
      child.addSpriteBoxReference(spriteBox);
    }
  }

  /// Adds a child to this node.
  ///
  /// The same node cannot be added to multiple nodes.
  ///
  ///     addChild(  Sprite(myImage));
  void addChild(Node child) {
    assert(child._parent == null);
    assert(_assertNonCircularAssignment(child));

    _childrenNeedSorting = true;
    _children.add(child);
    child._parent = this;
    child.addSpriteBoxReference(this._spriteBox);
    _childrenLastAddedOrder += 1;
    child._addedOrder = _childrenLastAddedOrder;
    if (_spriteBox != null) _spriteBox!.registerNode(child);
  }

  /// Removes a child from this node.
  void removeChild(Node child) {
    if (_children.remove(child)) {
      child._parent = null;
      child.removeSpriteBoxReference();
      if (_spriteBox != null) _spriteBox!.deregisterNode(child);
    }
  }

  /// Removes this node from its parent node.
  void removeFromParent() {
    if (_parent != null) {
      _parent!.removeChild(this);
    }
  }

  /// Removes all children of this node.
  void removeAllChildren() {
    for (Node child in _children) {
      child._parent = null;
      child._spriteBox = null;
    }
    _children = <Node>[];
    _childrenNeedSorting = false;
    if (_spriteBox != null) _spriteBox!.deregisterNode(null);
  }

  /// Removes all direct children of this node which are tagged with [tag].
  void removeChildrenWithTag(String tag) {
    // First find children from _children and collect them, then remove them.
    // We're doing this because we'll modify _children while removing them.
    final childrenToRemove = findChildrenWithTag(tag);
    childrenToRemove.forEach((child) => removeChild(child));
  }

  /// Finds all direct children of this node which are tagged with [tag].
  List<Node> findChildrenWithTag(String tag) {
    return _children.where((child) => child.tag == tag).toList(growable: false);
  }

  void _sortChildren() {
    // Sort children primarily by zPosition, secondarily by added order
    if (_childrenNeedSorting) {
      _children.sort((Node a, Node b) {
        if (a._zPosition == b._zPosition) {
          return a._addedOrder - b._addedOrder;
        } else if (a._zPosition > b._zPosition) {
          return 1;
        } else {
          return -1;
        }
      });
      _childrenNeedSorting = false;
    }
  }

  // Calculating the transformation matrix

  /// The transformMatrix describes the transformation from the node's parent.
  ///
  /// You cannot set the transformMatrix directly, instead use the position, rotation and scale properties.
  ///
  ///     Matrix4 matrix = myNode.transformMatrix;
  Matrix4? get transformMatrix {
    if (_transformMatrix == null) {
      _transformMatrix = computeTransformMatrix();
    }
    return _transformMatrix;
  }

  /// Computes the transformation matrix of this node. This method can be
  /// overridden if a custom matrix is required. There is usually no reason to
  /// call this method directly.
  Matrix4 orig_computeTransformMatrix() {
    double cx, sx, cy, sy;

    if (_rotation == 0.0) {
      cx = 1.0;
      sx = 0.0;
      cy = 1.0;
      sy = 0.0;
    } else {
      double radiansX = convertDegrees2Radians(_rotation);
      double radiansY = convertDegrees2Radians(_rotation);

      cx = math.cos(radiansX);
      sx = math.sin(radiansX);
      cy = math.cos(radiansY);
      sy = math.sin(radiansY);
    }

    // Create transformation matrix for scale, position and rotation
    Matrix4 matrix = Matrix4(
        cy * _scaleX,
        sy * _scaleX,
        0.0,
        0.0,
        -sx * _scaleY,
        cx * _scaleY,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        _position.dx,
        _position.dy,
        0.0,
        1.0);

    if (_skewX != 0.0 || _skewY != 0.0) {
      // Needs skew transform
      Matrix4 skew = Matrix4(
          1.0,
          math.tan(radians(_skewX)),
          0.0,
          0.0,
          math.tan(radians(_skewY)),
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0);
      matrix.multiply(skew);
    }

    return matrix;
  }

  /// Computes the transformation matrix of this node. This method can be
  /// overridden if a custom matrix is required. There is usually no reason to
  /// call this method directly.
  Matrix4 computeTransformMatrix() {
    final translateX = _position.dx - (size.width * _relativePositionAnchor.dx);
    final translateY =
        _position.dy - (size.height * _relativePositionAnchor.dy);
    final matrix = Matrix4.identity()..translate(translateX, translateY, 0.0);

    if (_scaleX != 1.0 || _scaleY != 1.0) {
      final hasPivot = _scalePivotPixels != null &&
          (_scalePivotPixels!.dx != 0 || _scalePivotPixels!.dy != 0);
      if (hasPivot) {
        matrix.translate(_scalePivotPixels!.dx, _scalePivotPixels!.dy);
      }

      matrix.scale(_scaleX, _scaleY, 1.0);
      if (hasPivot) {
        matrix.translate(-_scalePivotPixels!.dx, -_scalePivotPixels!.dy);
      }
    }

    if (_rotation != 0.0) {
      final hasPivot = _rotationPivotPixels != null &&
          (_rotationPivotPixels!.dx != 0 || _rotationPivotPixels!.dy != 0);
      if (hasPivot) {
        matrix.translate(_rotationPivotPixels!.dx, _rotationPivotPixels!.dy);
      }

      matrix.rotateZ(radians(_rotation));
      if (hasPivot) {
        matrix.translate(-_rotationPivotPixels!.dx, -_rotationPivotPixels!.dy);
      }
    }

    if (_skewX != 0.0 || _skewY != 0.0) {
      matrix.multiply(Matrix4.skew(radians(_skewX), radians(_skewY)));
    }

    return matrix;
  }

  /// Invalidates the current transform matrix. If the [computeTransformMatrix]
  /// method is overridden, this method should be called whenever a property
  /// changes that affects the matrix.
  void invalidateTransformMatrix() {
    _transformMatrix = null;
    _transformMatrixInverse = null;
    invalidateToBoxTransformMatrix();
  }

  void invalidateToBoxTransformMatrix() {
    _transformMatrixNodeToBox = null;
    _transformMatrixBoxToNode = null;

    for (Node child in children) {
      child.invalidateToBoxTransformMatrix();
    }
  }

  // Transforms to other nodes

  Matrix4? _nodeToBoxMatrix() {
    assert(_spriteBox != null);
    if (_transformMatrixNodeToBox != null) {
      return _transformMatrixNodeToBox;
    }

    if (_parent == null) {
      // Base case, we are at the top
      assert(this == _spriteBox!.rootNode);
      _transformMatrixNodeToBox = _spriteBox!.transformMatrix!.clone()
        ..multiply(transformMatrix!);
    } else {
      _transformMatrixNodeToBox = _parent!._nodeToBoxMatrix()!.clone()
        ..multiply(transformMatrix!);
    }
    return _transformMatrixNodeToBox;
  }

  Matrix4? _boxToNodeMatrix() {
    assert(_spriteBox != null);

    if (_transformMatrixBoxToNode != null) {
      return _transformMatrixBoxToNode;
    }

    _transformMatrixBoxToNode = _nodeToBoxMatrix()!.clone();
    _transformMatrixBoxToNode!.invert();

    return _transformMatrixBoxToNode;
  }

  /// The inverse transform matrix used by this node.
  Matrix4? get inverseTransformMatrix {
    if (_transformMatrixInverse == null) {
      _transformMatrixInverse = transformMatrix!.clone();
      _transformMatrixInverse!.invert();
    }
    return _transformMatrixInverse;
  }

  /// Converts a point from the coordinate system of the [SpriteBox] to the local coordinate system of the node.
  ///
  /// This method is particularly useful when handling pointer events and need the pointers position in a local
  /// coordinate space.
  ///
  ///     Point localPoint = myNode.convertPointToNodeSpace(pointInBoxCoordinates);
  Offset convertPointToNodeSpace(Offset boxPoint) {
    assert(_spriteBox != null);

    Vector4 v = _boxToNodeMatrix()!
        .transform(Vector4(boxPoint.dx, boxPoint.dy, 0.0, 1.0));
    return Offset(v[0], v[1]);
  }

  /// Converts a point from the local coordinate system of the node to the coordinate system of the [SpriteBox].
  ///
  ///     Point pointInBoxCoordinates = myNode.convertPointToBoxSpace(localPoint);
  Offset convertPointToBoxSpace(Offset nodePoint) {
    assert(_spriteBox != null);

    Vector4 v = _nodeToBoxMatrix()!
        .transform(Vector4(nodePoint.dx, nodePoint.dy, 0.0, 1.0));
    return Offset(v[0], v[1]);
  }

  /// Converts a [point] from another [node]s coordinate system into the local coordinate system of this node.
  ///
  ///     Point pointInNodeASpace = nodeA.convertPointFromNode(pointInNodeBSpace, nodeB);
  Offset convertPointFromNode(Offset point, Node node) {
    assert(_spriteBox != null);
    assert(_spriteBox == node._spriteBox);

    Offset boxPoint = node.convertPointToBoxSpace(point);
    Offset localPoint = convertPointToNodeSpace(boxPoint);

    return localPoint;
  }

  // Hit test

  /// Returns true if the [point] is inside the node, the [point] is in the local coordinate system of the node.
  ///
  ///     myNode.isPointInside(localPoint);
  ///
  /// Setting [size] provides a basic bounding box check for this method. If you require a more detailed check this
  /// method can be overridden.
  bool isPointInside(Offset nodePoint) {
    double minX = -size.width * _relativePositionAnchor.dx;
    double minY = -size.height * _relativePositionAnchor.dy;
    double maxX = minX + size.width;
    double maxY = minY + size.height;
    return (nodePoint.dx >= minX &&
        nodePoint.dx < maxX &&
        nodePoint.dy >= minY &&
        nodePoint.dy < maxY);
  }

  // Rendering

  void visit(Canvas canvas) {
    if (!visible) return;

    prePaint(canvas);
    _visitChildren(canvas);
    postPaint(canvas);
  }

  void prePaint(Canvas canvas) {
    canvas
      ..save()
      ..transform(transformMatrix!.storage);
  }

  /// If set, this will paint when [paint()] is called, if the method is not overridden.
  void Function(Canvas canvas)? customPainter;

  /// Paints this node to the canvas.
  ///
  /// Subclasses, such as [Sprite], override this method to do the actual painting of the node. To do custom
  /// drawing override this method and make calls to the [canvas] object. All drawing is done in the node's local
  /// coordinate system, relative to the node's position. Alternately, you can set a [customPainter] function to perform
  /// painting. This is a convenient way of making a custom painter node without having to subclass.
  void paint(Canvas canvas) {
    if (customPainter != null) {
      customPainter!(canvas);
    }
  }

  void _visitChildren(Canvas canvas) {
    // Sort children if needed
    _sortChildren();

    int i = 0;

    // Visit children behind this node
    while (i < _children.length) {
      Node child = _children[i];
      if (child.zPosition >= 0.0) break;
      child.visit(canvas);
      i++;
    }

    // Paint this node
    paint(canvas);

    // Visit children in front of this node
    while (i < _children.length) {
      Node child = _children[i];
      child.visit(canvas);
      i++;
    }
  }

  void postPaint(Canvas canvas) {
    canvas.restore();
  }

  // Receiving update calls

  /// Called before a frame is drawn.
  ///
  /// Override this method to do any updates to the node or node tree before it's drawn to screen.
  ///
  ///     // Make the node rotate at a fixed speed
  ///     void update(double dt) {
  ///       rotation = rotation * 10.0 * dt;
  ///     }
  void update(double dt) {}

  /// Called whenever the [SpriteBox] is modified or resized, or if the device is rotated.
  ///
  /// Override this method to do any updates that may be necessary to correctly display the node or node tree with the
  /// new layout of the [SpriteBox].
  ///
  ///     void spriteBoxPerformedLayout() {
  ///       // Move some stuff around here
  ///     }
  void spriteBoxPerformedLayout() {}

  // Handling user interaction

  /// The node will receive user interactions, such as pointer (touch or mouse) events.
  ///
  ///     class MyCustomNode extends Node {
  ///       userInteractionEnabled = true;
  ///     }
  bool get userInteractionEnabled => _userInteractionEnabled;

  set userInteractionEnabled(bool userInteractionEnabled) {
    _userInteractionEnabled = userInteractionEnabled;
    if (_spriteBox != null) _spriteBox!.eventTargets = null;
  }

  /// Handles an event, such as a pointer (touch or mouse) event.
  ///
  /// Override this method to handle events. The node will only receive events if the [userInteractionEnabled] property
  /// is set to true and the [isPointInside] method returns true for the position of the pointer down event (default
  /// behavior provided by [Node]). Unless [handleMultiplePointers] is set to true, the node will only receive
  /// events for the first pointer that is down.
  ///
  /// Alternately, you can set [eventHandler] and the default implementation will delegate to this function.
  ///
  /// Return true if the node has consumed the event, if an event is consumed it will not be passed on to nodes behind
  /// the current node.
  ///
  ///     // MyTouchySprite gets transparent when we touch it
  ///     class MyTouchySprite extends Sprite {
  ///
  ///       MyTouchySprite(Image img) : super (img) {
  ///         userInteractionEnabled = true;
  ///       }
  ///
  ///       bool handleEvent(SpriteBoxEvent event) {
  ///         if (event.type is PointerDownEvent) {
  ///           opacity = 0.5;
  ///         }
  ///         else if (event.type is PointerUpEvent) {
  ///           opacity = 1.0;
  ///         }
  ///         return true;
  ///       }
  ///     }
  bool handleEvent(SpriteBoxEvent event) {
    if (eventHandler != null) {
      return eventHandler!(event);
    }

    return false;
  }
}
