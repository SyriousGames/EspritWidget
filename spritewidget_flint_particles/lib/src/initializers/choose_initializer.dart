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

/// The ChooseInitializer initializer selects one of multiple initializers, using
/// optional weighting values to produce an uneven distribution for the choice,
/// and applies it to the particle. This is often used with the InitializerGroup
/// initializer to apply a randomly chosen group of initializers to the particle.
///
/// @see org.flintparticles.common.initializers.InitializerGroup
class ChooseInitializer extends InitializerBase {
  WeightedList<Initializer> _initializers = WeightedList();

  ChooseInitializer();

  void addInitializer(Initializer initializer, [double weight = 1]) {
    _initializers.add(initializer, weight);
  }

  @override
  void initialize(Emitter emitter, Particle particle) {
    Initializer initializer = _initializers.getRandomValue();
    initializer.initialize(emitter, particle);
  }
}
