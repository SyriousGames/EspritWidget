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

/// The InitializerGroup initializer collects a number of initializers into a single
/// larger initializer that applies all the grouped initializers to a particle. It is
/// commonly used with the ChooseInitializer initializer to choose from different
/// groups of initializers when initializing a particle.
///
/// @see org.flintparticles.common.initializers.ChooseInitializer
class InitializerGroup extends InitializerBase {
  late List<Initializer> _initializers;

  /// The constructor creates an InitializerGroup. The added initializers will be sorted by priority.
  ///
  /// @param initializers Initializers that should be added to the group.
  InitializerGroup(List<Initializer> _initializers) {
    this._initializers = List.from(_initializers);
    this._initializers.sort((a, b) => a.priority - b.priority);
  }

  @override
  void addedToEmitter(Emitter emitter) {
    _initializers.forEach((i) => i.addedToEmitter(emitter));
  }

  @override
  void removedFromEmitter(Emitter emitter) {
    _initializers.forEach((i) => i.removedFromEmitter(emitter));
  }

  @override
  void initialize(Emitter emitter, Particle particle) {
    _initializers.forEach((i) => i.initialize(emitter, particle));
  }
}
