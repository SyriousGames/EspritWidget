/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2011
 * http://flintparticles.org/
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

/// A set of easing equations that start and end at the end value and reach the start value
/// at the half-time point. They are designed for modifying the particle energy such that it
/// starts and ends at zero and peaks at half way through the particle's lifetime.
///
/// @see org.flintparticles.common.actions.Age
class TwoWay {
  /// Gives a linear increase and decrease in energy either side of the centre point.
  static double linear(double t, double b, double c, double d) {
    if ((t = 2 * t / d) <= 1) {
      return (1 - t) * c + b;
    }
    return (t - 1) * c + b;
  }

  /// Energy increases and then decreases as if following the top half of a circle.
  static double circular(double t, double b, double c, double d) {
    t = 1 - (2 * t / d);
    return (1 - sqrt(1 - t * t)) * c + b;
  }

  /// Energy follows the first half of a sine wave.
  static double sine(double t, double b, double c, double d) {
    return (1 - sin(pi * t / d)) * c + b;
  }

  /// Eases towards the middle using a quadratic curve.
  static double quadratic(double t, double b, double c, double d) {
    t = 1 - (2 * t / d);
    return t * t * c + b;
  }

  /// Eases towards the middle using a cubic curve.
  static double cubic(double t, double b, double c, double d) {
    t = 1 - (2 * t / d);
    if (t < 0) t = -t;
    return t * t * t * c + b;
  }

  /// Eases towards the middle using a quartic curve.
  static double quartic(double t, double b, double c, double d) {
    t = 1 - (2 * t / d);
    return t * t * t * t * c + b;
  }

  /// Eases towards the middle using a qintic curve.
  static double qintic(double t, double b, double c, double d) {
    t = 1 - (2 * t / d);
    if (t < 0) t = -t;
    return t * t * t * t * t * c + b;
  }
}
