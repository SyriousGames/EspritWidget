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

/// The ColorInit Initializer sets the color of the particle.

class ColorInit extends InitializerBase {
  Color minColor;
  Color maxColor;

  /// The constructor creates a ColorInit initializer for use by
  /// an emitter. To add a ColorInit to all particles created by an emitter, use the
  /// emitter's addInitializer method.
  ///
  /// <p>The color of particles initialized by this class
  /// will be a random value between the two values passed to
  /// the constructor. For a fixed value, pass the same color
  /// in for both parameters.</p>
  ///
  /// @param minColor the color at one end of the color range to use.
  /// @param maxColor the color at the other end of the color range to use.
  ColorInit(this.minColor, this.maxColor);

  @override
  void initialize(Emitter emitter, Particle particle) {
    particle.color = maxColor == minColor
        ? minColor
        : interpolateColors(minColor, maxColor, Random().nextDouble());
  }
}
