import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart' hide Layer;

import 'button_node.dart';
import 'label.dart';
import 'layer.dart';
import 'motion.dart';
import 'nine_slice_sprite.dart';
import 'node.dart';
import 'sprite.dart';
import 'sprite_box.dart';

enum MenuVertAlign { top, center, bottom }

/// A simple vertical menu.
///
/// The menu items roll-down like a shade when it is displayed. The size of the menu determines the height within which
/// the menu items are laid out. The children of the [Menu] must be [MenuItems]. If you change the size after construction,
/// you must call [resetAndLayout()].
///
/// While this class and [MenuItem] implement the mechanics of the menu, [MenuBuilder] makes it easier to construct
/// a menu.
class Menu extends Layer {
  double verticalGap;
  MenuVertAlign verticalAlignment;

  /// An event callback which fires immediately after the user selects an item, but before
  /// animations are complete and the final [MenuItem.onSelected] callback is called. E.g., this allows you to play a sound
  /// while the animations occur.
  EventCallback? onPreSelected;

  bool _itemFiring = false;

  /// Construct a [Menu].
  Menu({
    this.verticalGap = 10,
    this.verticalAlignment = MenuVertAlign.center,
    size = Size.zero,
    this.onPreSelected,
  }) : super(size: size) {
    resetAndLayout();
  }

  @override
  void addChild(Node child) {
    super.addChild(child);
    resetAndLayout();
  }

  @override
  void removeChild(Node child) {
    super.removeChild(child);
    resetAndLayout();
  }

  @override
  void removeAllChildren() {
    super.removeAllChildren();
    resetAndLayout();
  }

  /// Resets the menu so it can be used again.
  void resetAndLayout() {
    _itemFiring = false;
    _calculateLayout();
  }

  /// Gets the rectangle bounding the actual menu.
  ///
  /// This can be different than [size] because it represents only the bounding size of the menu items.
  get menuBounds {
    _calculateLayout();
    return _menuBounds;
  }

  Rect _menuBounds = Rect.zero;

  void _calculateLayout() {
    final screenCenterX = size.width / 2;
    var totalHeight = 0.0;
    var maxWidth = 0.0;
    for (Node item in children) {
      totalHeight += item.size.height + verticalGap;
      var width = item.size.width;
      if (width > maxWidth) {
        maxWidth = width;
      }
    }

    double y = 0.0;
    if (verticalAlignment == MenuVertAlign.top) {
      y = verticalGap;
    } else if (verticalAlignment == MenuVertAlign.center) {
      y = (size.height - totalHeight) / 2;
    } else if (verticalAlignment == MenuVertAlign.bottom) {
      y = size.height - totalHeight;
    }

    final left = screenCenterX - maxWidth / 2;
    _menuBounds = Rect.fromLTRB(left, y, left + maxWidth, y + totalHeight);

    final fallDownTime = 1.0;
    double top = y;
    motions.stopAll();
    for (final Node nodeItem in children) {
      final item = nodeItem as MenuItem;
      var x = left;

      // Fall-down animation.
      final endingOpacity = item.enabled ? 1.0 : 0.5;
      item.position = Offset(x, top);
      motions.run(MotionGroup([
        MotionTween((v) => item.position = Offset(x, v), top, y, fallDownTime,
            Curves.bounceOut),
        MotionTween(
            (v) => item.opacity = v, 0.0, endingOpacity, fallDownTime / 2),
      ]));
      y += item.size.height + verticalGap;
    }
  }

  void _onMenuItemSelected(MenuItem menuItem, SpriteBoxEvent event) {
    // Don't allow simultaneous fires.
    if (_itemFiring) {
      return;
    }

    // Stop taking selections until menuItem.onSelect is complete.
    _itemFiring = true;
    if (onPreSelected != null) {
      onPreSelected!(event);
    }

    // Animation to take out unselected menu items. They fall away.
    final fallOutTime = 0.5;
    for (final Node nodeItem in children) {
      final item = nodeItem as MenuItem;
      if (item != menuItem) {
        motions.run(MotionGroup([
          MotionTween((v) => item.position = Offset(item.position.dx, v),
              item.position.dy, size.height, fallOutTime, Curves.easeOutCubic),
          MotionTween(
              (v) => item.opacity = v, item.opacity, 0.0, fallOutTime / 2),
        ]));
      }
    }

    motions.run(MotionSequence([
      MotionDelay(fallOutTime),
      if (menuItem.onSelected != null)
        MotionCallFunction(() => menuItem.onSelected!(event)),
      MotionCallFunction(() => resetAndLayout()),
    ]));
  }
}

/// A menu item container used by [Menu].
///
/// A [MenuItem] is composed of child elements, such as background and a label. The parent of a [MenuItem] must be a
/// [Menu]. Also, the [size] of the menu item must be set prior to [Menu.resetAndLayout()] being invoked. The easiest
/// way to do this is to set it before adding it to the [Menu].
class MenuItem extends ButtonWithPressEffects {
  EventCallback? onSelected;

  /// Constructs a [MenuItem].
  ///
  /// [onSelected] is a callback invoked when the item is selected. Do not set [onTriggered].
  MenuItem({this.onSelected}) {
    onTriggered = (event) => (parent as Menu)._onMenuItemSelected(this, event);
  }

  @override
  get enabled => super.enabled;

  set enabled(enabled) {
    super.enabled = enabled;
    opacity = enabled ? 1.0 : 0.5;
  }
}

class MenuBuilder {
  /// The size of the area the menu will appear in. The menu will be aligned within this area as specified by [verticalAlignment].
  final Size size;

  /// How the menu should be vertically aligned within [size].
  var verticalAlignment = MenuVertAlign.center;

  /// Left/right padding when adding text the menu item.
  var leftRightPadding = 10.0;

  /// Top/bottom padding when adding text the menu item.
  var topBottomPadding = 5.0;

  /// Vertical gap between menu items.
  var verticalGap = 10.0;

  /// Target text style used to draw the menu item labels. This font size in this style represents the largest to use.
  /// The actual text style used may have a small font size in order to accommodate [maxWidth].
  TextStyle textStyle = const TextStyle();

  /// The maximum width that a menu item should consume. Defaults to [double.infinity] for no limit.
  var maxItemWidth = double.infinity;

  /// Used to create a background image for the menu item. Works best with [imageIsNineSliceable] == true.
  Image? bkgImage = null;

  /// If [bkgImage] is suitable for use in a [NineSliceSprite], this is the nine-slice center rectangle.
  Rect? bkgNineSliceCenterRect = null;

  /// If you don't use [bkgImage], this is a factory method to create a [Node] for the menu item background.
  Node Function(Size size)? bkgNodeFactory;

  /// An event callback which fires immediately after the user selects an item, but before
  /// animations are complete and the final [MenuItem.onSelected] callback is called. E.g., this allows you to play a sound
  /// while the animations occur.
  EventCallback? onPreSelected;

  List<_MenuItemDef> _menuItemDefs = [];

  MenuBuilder(this.size);

  addItem(String label, {EventCallback? onSelected, bool enabled = true}) {
    final def = _MenuItemDef(label)
      ..menuItem.onSelected = onSelected
      ..menuItem.enabled = enabled;
    _menuItemDefs.add(def);
  }

  Menu build() {
    final menu = Menu(
        size: size,
        verticalGap: verticalGap,
        verticalAlignment: verticalAlignment,
        onPreSelected: onPreSelected);

    var actualTextStyle = textStyle;
    double maxWidth = 0.0, maxHeight;
    while (true) {
      maxWidth = 0.0;
      maxHeight = 0.0;
      _menuItemDefs.forEach((def) {
        def.label = Label(
          def.labelText,
          textAlign: TextAlign.center,
          textStyle: actualTextStyle,
          layoutWidth: null, // We'll need to set this later.
        );

        maxWidth = max(maxWidth, def.label.naturalWidth);
        maxHeight = max(maxHeight, def.label.naturalHeight);
      });

      if (maxWidth <= maxItemWidth) {
        break;
      }

      // We don't fit, reduce the text size by 1 logical pixel
      actualTextStyle =
          actualTextStyle.copyWith(fontSize: actualTextStyle.fontSize! - 1);
    }

    final itemWidth = maxWidth + leftRightPadding * 2;
    final itemHeight = maxHeight + topBottomPadding * 2;
    final itemSize = Size(itemWidth, itemHeight);

    _menuItemDefs.forEach((def) {
      if (bkgImage != null) {
        if (bkgNineSliceCenterRect == null) {
          Node sprite = Sprite.fromImage(bkgImage!);
          sprite.size = itemSize;
          def.menuItem.addChild(sprite);
        } else {
          def.menuItem.addChild(NineSliceSprite(
            bkgImage!,
            size: itemSize,
            centerRect: bkgNineSliceCenterRect!,
          ));
        }
      } else if (bkgNodeFactory != null) {
        def.menuItem.addChild(bkgNodeFactory!(itemSize));
      }

      def.label.layoutWidth = maxWidth;
      // Center label vertically within the item.
      def.label.position =
          Offset(leftRightPadding, (itemHeight - def.label.naturalHeight) / 2);
      def.menuItem.size = itemSize;
      def.menuItem.layerRect = Rect.fromLTWH(0, 0, itemWidth, itemHeight);
      def.menuItem.addChild(def.label);

      menu.addChild(def.menuItem);
    });

    return menu;
  }
}

class _MenuItemDef {
  String labelText;
  MenuItem menuItem = MenuItem();

  /// Created during calculation.
  late Label label;

  _MenuItemDef(this.labelText);
}
