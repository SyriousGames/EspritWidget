/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2011
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:  
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

part of flint_particles;

/// Sets the color of the particle based on a zone.
///
/// The color of particles initialized by this class
/// will be a value chosen from the zone between the two values passed to
/// the constructor and the X axis of the zone.
class ColorZoneInit extends InitializerBase {
  /// The color at one end of the color range to use.
  Color minColor;

  /// The color at the other end of the color range to use.
  Color maxColor;

  /// The zone to choose the ratio between the two colors. Only the X position of the zone is used, so a horizontal
  /// line zone is probably the best choice.
  Zone zone;

  ColorZoneInit(this.minColor, this.maxColor, this.zone);

  @override
  void initialize(Emitter emitter, Particle particle) {
    particle.color = maxColor == minColor
        ? minColor
        : interpolateColors(minColor, maxColor, zone.getLocation().x);
  }
}