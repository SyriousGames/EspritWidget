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

/// The ScaleAllsInit initializer sets the scale of the particles image
/// and adjusts its mass and collision radius accordingly. It selects
/// one of multiple scales, using optional weighting values to produce an uneven
/// distribution for the scales.
///
/// <p>If you want to adjust only the image size use
/// the ScaleImageInit initializer.</p>
///
/// <p>This initializer has a priority of -10 to ensure it occurs after
/// mass and radius assignment classes like CollisionRadiusInit and MassInit.</p>
///
/// Was previous called ScaleAllsInit.
/// @see org.flintparticles.common.initializers.ScaleImagesInit
class ScaleAllDistributedInit extends InitializerBase {
  WeightedList<double> _scales = WeightedList();

  void addScale(double scale, [double weight = 1]) {
    _scales.add(scale, weight);
  }

  @override
  void initialize(Emitter emitter, Particle particle) {
    double scale = _scales.getRandomValue();
    particle.scale = scale;
    particle.mass *= scale * scale;
    particle.collisionRadius *= scale;
  }
}
