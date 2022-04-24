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

/// The TargetVelocity action adjusts the velocity of the particle towards the
/// target velocity.
class TargetVelocity extends ActionBase {
  /// The x coordinate of the target velocity, in pixels per second.s
  double targetVelocityX;

  /// The y coordinate of the target velocity, in pixels per second.
  double targetVelocityY;

  /// Adjusts how quickly the particle reaches the target velocity.
  /// Larger numbers cause it to approach the target velocity more quickly.
  double rate;

  /// The constructor creates a TargetVelocity action for use by an emitter.
  /// To add a TargetVelocity to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param velX The x coordinate of the target velocity, in pixels per second.
  /// @param velY The y coordinate of the target velocity, in pixels per second.
  /// @param rate Adjusts how quickly the particle reaches the target velocity.
  /// Larger numbers cause it to approach the target velocity more quickly.
  TargetVelocity(
      [this.targetVelocityX = 0, this.targetVelocityY = 0, this.rate = 0.1]);

  /// Calculates the difference between the particle's velocity and
  /// the target and adjusts the velocity closer to the target by an
  /// amount proportional to the difference, the time and the rate of convergence.
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
    p.velX += (targetVelocityX - p.velX) * rate * time;
    p.velY += (targetVelocityY - p.velY) * rate * time;
  }
}
