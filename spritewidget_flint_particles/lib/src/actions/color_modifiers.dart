part of flint_particles;

/// Alters some value of the particle's color as it ages.
///
/// The particle must have been initialized to a specific color.
/// The action uses the particle's energy level to decide how to modify the color.
///
/// This action should be used in conjunction with the Age action.
class BaseColorModifier extends ActionBase {
  /// The value to apply to the particle's color when its energy is 1.
  final double startValue;

  /// The value to apply to the particle's color when its energy is 0.
  final double endValue;
  final double _range;

  /// A function which modifies the color by a given value.
  final Color Function(Color, double) colorFn;

  /// The curve to apply to the color value interpolation.
  Curve curve;

  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  /// [colorFn] a function which modifies a color given an interpolated value.
  BaseColorModifier(this.startValue, this.endValue, this.colorFn,
      {this.curve = Curves.linear})
      : _range = endValue - startValue;

  @override
  void update(Emitter emitter, Particle particle, double time) {
    Color? initialColor = particle.dictionary['colorModifierInitialColor'];
    if (initialColor == null) {
      initialColor = particle.color;
      particle.dictionary['colorModifierInitialColor'] = initialColor;
    }

    final value =
        startValue + (_range * (1.0 - curve.transform(particle.energy)));
    particle.color = colorFn(initialColor, value);
  }
}

/// ColorLightness alters the lightness of the particle's color as it ages.
///
/// The particle must have been initialized to a specific color - preferably
/// not white. The action uses the particle's energy level to decide how to
/// lighten the color.
///
/// This action should be used in conjunction with the Age action.
class ColorLightness extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100. 100 is white.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorLightness(double startValue, double endValue,
      {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.lighten(value.round()),
            curve: curve);
}

/// ColorBrightness alters the brightness of the particle's color as it ages.
///
/// The particle must have been initialized to a specific color.
/// The action uses the particle's energy level to decide how to
/// brighten the color.
///
/// This action should be used in conjunction with the Age action.
class ColorBrightness extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100. 100 is brightest.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorBrightness(double startValue, double endValue,
      {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.brighten(value.round()),
            curve: curve);
}

/// ColorDarkness alters the darkness of the particle's color as it ages.
///
/// The particle must have been initialized to a specific color - preferably
/// not black. The action uses the particle's energy level to decide how to
/// darken the color.
///
/// This action should be used in conjunction with the Age action.
class ColorDarkness extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100. 100 is white.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorDarkness(double startValue, double endValue,
      {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.darken(value.round()),
            curve: curve);
}

/// ColorTint alters the tint of the particle's color as it ages. This mixes
/// the color with pure white.
///
/// The particle must have been initialized to a specific color - preferably
/// not white. The action uses the particle's energy level to decide how to
/// tint the color.
///
/// This action should be used in conjunction with the Age action.
/// NOTE 2020-11-25 fixed on my fork of TinyColor (mix())
class ColorTint extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100. 100 is white.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorTint(double startValue, double endValue, {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.tint(value.round()),
            curve: curve);
}

/// ColorShade alters the shade of the particle's color as it ages. This mixes
/// the color with pure white.
///
/// The particle must have been initialized to a specific color - preferably
/// not black. The action uses the particle's energy level to decide how to
/// shade the color.
///
/// This action should be used in conjunction with the Age action.
/// NOTE 2020-11-25 fixed on my fork of TinyColor (mix())
class ColorShade extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100. 100 is black.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorShade(double startValue, double endValue, {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.shade(value.round()),
            curve: curve);
}

/// ColorDesaturate alters the desaturation of the particle's color as it ages.
///
/// The particle must have been initialized to a specific color - preferably
/// not white. The action uses the particle's energy level to decide how to
/// desaturate the color.
///
/// This action should be used in conjunction with the Age action.
class ColorDesaturate extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100. 100 is will make it greyscale.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorDesaturate(double startValue, double endValue,
      {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.desaturate(value.round()),
            curve: curve);
}

/// ColorSaturate alters the saturation of the particle's color as it ages.
///
/// The particle must have been initialized to a specific color - preferably
/// not white. The action uses the particle's energy level to decide how to
/// saturate the color.
///
/// This action should be used in conjunction with the Age action.
class ColorSaturate extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value 0 to 100.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value 0 to 100.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorSaturate(double startValue, double endValue,
      {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.saturate(value.round()),
            curve: curve);
}

/// ColorSpinHue alters the hue of the particle's color as it ages. The
/// hue can be spun from -360 to 360.
///
/// The particle must have been initialized to a specific color - preferably
/// not white. The action uses the particle's energy level to decide how to
/// spin the color.
///
/// This action should be used in conjunction with the Age action.
class ColorSpinHue extends BaseColorModifier {
  /// Creates the action for use by an emitter.
  ///
  /// [startValue] is the value to apply to the particle's color when its energy is 1.
  /// Value -360 to 360. 0, 360, and -360 are the same as the original color.
  /// [endValue] is the value to apply to the particle's color when its energy is 0.
  /// Value -360 to 360. 0, 360, and -360 are the same as the original color.
  /// [curve] an optional curve to apply to the value interpolation. Defaults
  /// to [Curves.linear].
  ColorSpinHue(double startValue, double endValue,
      {Curve curve = Curves.linear})
      : super(startValue, endValue,
            (Color color, double value) => color.spin(value),
            curve: curve);
}
