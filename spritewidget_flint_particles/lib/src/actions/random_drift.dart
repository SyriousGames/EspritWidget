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

/// The RandomDrift action moves the particle by a random small amount every
/// frame, causing the particle to drift around.

class RandomDrift extends ActionBase {
  late double _sizeX;
  late double _sizeY;

  /// The constructor creates a RandomDrift action for use by an emitter.
  /// To add a RandomDrift to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param driftX The maximum amount of horizontal drift in pixels per second.
  /// @param driftY The maximum amount of vertical drift in pixels per second.
  RandomDrift([double driftX = 0, double driftY = 0]) {
    this.driftX = driftX;
    this.driftY = driftY;
  }

  /// The maximum amount of horizontal drift in pixels per second.
  double get driftX {
    return _sizeX / 2;
  }

  set driftX(double value) {
    _sizeX = value * 2;
  }

  /// The maximum amount of vertical drift in pixels per second.
  double get driftY {
    return _sizeY / 2;
  }

  set driftY(double value) {
    _sizeY = value * 2;
  }

  /// Calculates a random drift for this frame and applies it for the
  /// period of time indicated.
  ///
  /// <p>This method is called by the emitter and need not be called by the
  /// user.</p>
  ///
  /// @param emitter The Emitter that created the particle.
  /// @param particle The particle to be updated.
  /// @param time The duration of the frame - used for time based updates.
  ///
  /// @see org.flintparticles.common.actions.Action#update()
  @override
  void update(Emitter emitter, Particle particle, double time) {
    Particle p = particle;
    final random = Random();
    p.velX += (random.nextDouble() - 0.5) * _sizeX * time;
    p.velY += (random.nextDouble() - 0.5) * _sizeY * time;
  }
}
