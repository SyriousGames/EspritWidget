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

/// The BoundingBox action confines each particle to a rectangle region. The
/// particle bounces back off the sides of the rectangle when it reaches
/// the edge. The bounce treats the particle as a circular body. By default,
/// no energy is lost in the collision. This can be modified by setting the
/// bounce property to a value other than 1, its default value.
///
/// This action has a priority of -20, so that it executes after
/// all movement has occured.

class BoundingBox extends ActionBase {
  /// The left coordinate of the bounding box.
  double left;

  /// The top coordinate of the bounding box.
  double top;

  /// The right coordinate of the bounding box.
  double right;

  /// The bottom coordinate of the bounding box.
  double bottom;

  /// The coefficient of restitution when the particles bounce off the
  /// sides of the box. A value of 1 gives a pure pure elastic collision, with no energy loss.
  /// A value between 0 and 1 causes the particle to loose enegy in the collision. A value
  /// greater than 1 causes the particle to gain energy in the collision.
  double bounce;

  /// The constructor creates a BoundingBox action for use by
  /// an emitter. To add a BoundingBox to all particles created by an emitter,
  /// use the emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param left The left coordinate of the box.
  /// @param top The top coordinate of the box.
  /// @param right The right coordinate of the box.
  /// @param bottom The bottom coordinate of the box.
  /// @param bounce The coefficient of restitution when the particles bounce off the
  /// sides of the box. A value of 1 gives a pure elastic collision, with no energy loss.
  /// A value between 0 and 1 causes the particle to loose energy in the collision. A value
  /// greater than 1 causes the particle to gain energy in the collision.
  BoundingBox(
      [this.left = 0,
      this.top = 0,
      this.right = 0,
      this.bottom = 0,
      this.bounce = 1]);

  /// Tests whether the particle is at the edge of the box and, if so,
  /// adjusts its velocity to bounce in back towards the center of the
  /// box.
  ///
  /// <p>This method is called by the emitter and need not be called by the
  /// user</p>
  ///
  /// @param emitter The Emitter that created the particle.
  /// @param particle The particle to be updated.
  /// @param time The duration of the frame - used for time based updates.
  ///
  /// @see org.flintparticles.common.actions.Action#update()
  @override
  void update(Emitter emitter, Particle particle, double time) {
    Particle p = particle;
    double radius = particle.collisionRadius;
    double position;
//    bool collided = false;
    if (p.velX > 0 && (position = p.x + radius) >= right) {
      p.velX = -p.velX * bounce;
      p.x += 2 * (right - position);
//      collided = true;
    } else if (p.velX < 0 && (position = p.x - radius) <= left) {
      p.velX = -p.velX * bounce;
      p.x += 2 * (left - position);
//      collided = true;
    }
    if (p.velY > 0 && (position = p.y + radius) >= bottom) {
      p.velY = -p.velY * bounce;
      p.y += 2 * (bottom - position);
//      collided = true;
    } else if (p.velY < 0 && (position = p.y - radius) <= top) {
      p.velY = -p.velY * bounce;
      p.y += 2 * (top - position);
//      collided = true;
    }

//    if (collided) {
//      if (emitter.hasEventListener(ParticleEvent.BOUNDING_BOX_COLLISION)) {
//        emitter.dispatchEvent(ParticleEvent(ParticleEvent.BOUNDING_BOX_COLLISION, p));
//      }
//    }
  }
}
