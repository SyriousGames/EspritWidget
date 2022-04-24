# EspritWidget

This is the monorepo for the EspritWidget project. It contains
two sub-projects: `spritewidget` and `spritewidget_flint_particles`.

## SpriteWidget (`spritewidget/`)

This project is a derivative of the Flutter SpriteWidget project (https://github.com/spritewidget/spritewidget)
which had been abandoned. There are new features and bug fixes since it was forked from SpriteWidget,
so it seemed appropriate to just create a separate project for it instead of a direct
fork from the SpriteWidget repo.

Some additional features include:

- Null-safety
- Lottie animation support - https://lottiefiles.com/
- SVG support, and more generically `Picture` nodes.
- A TrailNode useful for generating trail effects
- Support for various types of sprite anchoring
- Support for "painters" which can be used to compose sprites without
  needing textures or images.
- Inclusion of tinycolor - another abandoned project (https://github.com/FooStudio/tinycolor)
  but now revived at https://github.com/TinyCommunity/tinycolor2.

There was support for Flare animations, but this was broken with the changeover Rive.
https://rive.app/

This project is currently being used in our game development, but it is in a
"works for us" state. We'll entertain PRs, but we don't plan to actively provide
support for it, or fix issues other than our own. You might get support, but we cannot
guarantee it.

## Flint Particles (`spritewidget_flint_particles/`)

A port of the Flash/AS3 Flint Particle System to Dart and Flutter.

To edit particles, we use the "Free Texture Packer" app. See: http://free-tex-packer.com/

This is a hand-tuned port of the Flint Particle system from ActionScript 3 to Dart/Flutter.
Only the 2D aspects of the library have been ported and distinctions between classes such as Particle
and Particle have been eliminated.

For the original Flint particle system see:

- https://www.richardlord.net/flint-particles/
- https://github.com/richardlord/Flint
