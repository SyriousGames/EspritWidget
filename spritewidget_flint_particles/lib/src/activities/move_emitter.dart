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

/// The MoveEmitter activity moves the emitter at a constant velocity.
class MoveEmitter extends ActivityBase {
  /// The x coordinate of the velocity to move the emitter,
  /// in pixels per second
  double velX;

  /// The y coordinate of the velocity to move the emitter,
  /// in pixels per second
  double velY;

  /// The constructor creates a MoveEmitter activity for use by
  /// an emitter. To add a MoveEmitter to an emitter, use the
  /// emitter's addActvity method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addActivity()
  ///
  /// @param x The x coordinate of the velocity to move the emitter,
  /// in pixels per second.
  /// @param y The y coordinate of the velocity to move the emitter,
  /// in pixels per second.
  MoveEmitter([this.velX = 0, this.velY = 0]);

  @override
  void update(Emitter emitter, double time) {
    emitter.position += Offset(velX * time, velY * time);
  }
}
