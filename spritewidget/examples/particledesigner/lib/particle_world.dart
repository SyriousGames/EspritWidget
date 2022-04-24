import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class ParticleWorld extends Node {
  ParticleSystem? particleSystem;

  final ImageMap? images;

  int _selectedTexture = 5;

  int get selectedTexture => _selectedTexture;

  set selectedTexture(int texture) {
    particleSystem!.texture =
        SpriteTexture(images!['assets/particle-$texture.png']!);
    _selectedTexture = texture;
  }

  ParticleWorld({this.images}) {
    size = const Size(1024.0, 1024.0);
    userInteractionEnabled = true;

    SpriteTexture texture =
        SpriteTexture(images!['assets/particle-$_selectedTexture.png']!);

    particleSystem = ParticleSystem(
      texture,
      autoRemoveOnFinish: false,
    );
    particleSystem!.position = const Offset(512.0, 512.0);
    particleSystem!.insertionOffset = Offset.zero;
    addChild(particleSystem!);
  }

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type is PointerDownEvent || event.type is PointerMoveEvent) {
      particleSystem!.insertionOffset =
          convertPointToNodeSpace(event.boxPosition) -
              const Offset(512.0, 512.0);
    }

    if (event.type is PointerDownEvent) {
      particleSystem!.reset();
    }

    return true;
  }
}
