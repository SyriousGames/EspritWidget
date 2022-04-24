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

/// The RectangleZone zone defines a rectangular shaped zone.
class RectangleZone implements Zone {
  Rect rect;

  /// The constructor creates a RectangleZone zone.
  RectangleZone(this.rect);

  /// The contains method determines whether a point is inside the zone.
  /// This method is used by the initializers and actions that
  /// use the zone. Usually, it need not be called directly by the user.
  ///
  /// @param x The x coordinate of the location to test for.
  /// @param y The y coordinate of the location to test for.
  /// @return true if point is inside the zone, false if it is outside.
  bool contains(double x, double y) {
    return rect.contains(Offset(x, y));
  }

  /// The getLocation method returns a random point inside the zone.
  /// This method is used by the initializers and actions that
  /// use the zone. Usually, it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  Point<double> getLocation() {
    return Point(rect.left + Random().nextDouble() * rect.width,
        rect.top + Random().nextDouble() * rect.height);
  }

  /// The getArea method returns the size of the zone.
  /// This method is used by the MultiZone class. Usually,
  /// it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  double getArea() {
    return rect.width * rect.height;
  }

  /// Manages collisions between a particle and the zone. Particles will collide with the edges
  /// of the rectangle defined for this zone, from inside or outside the zone. The collisionRadius
  /// of the particle is used when calculating the collision.
  ///
  /// @param particle The particle to be tested for collision with the zone.
  /// @param bounce The coefficient of restitution for the collision.
  ///
  /// @return Whether a collision occured.
  bool collideParticle(Particle particle, [double bounce = 1]) {
    double position;
    double previousPosition;
    double intersect;
    bool collision = false;

    if (particle.velX > 0) {
      position = particle.x + particle.collisionRadius;
      previousPosition = particle.previousX + particle.collisionRadius;
      if (previousPosition < rect.left && position >= rect.left) {
        intersect = particle.previousY +
            (particle.y - particle.previousY) *
                (rect.left - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.top - particle.collisionRadius &&
            intersect <= rect.bottom + particle.collisionRadius) {
          particle.velX = -particle.velX * bounce;
          particle.x += 2 * (rect.left - position);
          collision = true;
        }
      } else if (previousPosition <= rect.right && position > rect.right) {
        intersect = particle.previousY +
            (particle.y - particle.previousY) *
                (rect.right - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.top - particle.collisionRadius &&
            intersect <= rect.bottom + particle.collisionRadius) {
          particle.velX = -particle.velX * bounce;
          particle.x += 2 * (rect.right - position);
          collision = true;
        }
      }
    } else if (particle.velX < 0) {
      position = particle.x - particle.collisionRadius;
      previousPosition = particle.previousX - particle.collisionRadius;
      if (previousPosition > rect.right && position <= rect.right) {
        intersect = particle.previousY +
            (particle.y - particle.previousY) *
                (rect.right - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.top - particle.collisionRadius &&
            intersect <= rect.bottom + particle.collisionRadius) {
          particle.velX = -particle.velX * bounce;
          particle.x += 2 * (rect.right - position);
          collision = true;
        }
      } else if (previousPosition >= rect.left && position < rect.left) {
        intersect = particle.previousY +
            (particle.y - particle.previousY) *
                (rect.left - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.top - particle.collisionRadius &&
            intersect <= rect.bottom + particle.collisionRadius) {
          particle.velX = -particle.velX * bounce;
          particle.x += 2 * (rect.left - position);
          collision = true;
        }
      }
    }

    if (particle.velY > 0) {
      position = particle.y + particle.collisionRadius;
      previousPosition = particle.previousY + particle.collisionRadius;
      if (previousPosition < rect.top && position >= rect.top) {
        intersect = particle.previousX +
            (particle.x - particle.previousX) *
                (rect.top - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.left - particle.collisionRadius &&
            intersect <= rect.right + particle.collisionRadius) {
          particle.velY = -particle.velY * bounce;
          particle.y += 2 * (rect.top - position);
          collision = true;
        }
      } else if (previousPosition <= rect.bottom && position > rect.bottom) {
        intersect = particle.previousX +
            (particle.x - particle.previousX) *
                (rect.bottom - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.left - particle.collisionRadius &&
            intersect <= rect.right + particle.collisionRadius) {
          particle.velY = -particle.velY * bounce;
          particle.y += 2 * (rect.bottom - position);
          collision = true;
        }
      }
    } else if (particle.velY < 0) {
      position = particle.y - particle.collisionRadius;
      previousPosition = particle.previousY - particle.collisionRadius;
      if (previousPosition > rect.bottom && position <= rect.bottom) {
        intersect = particle.previousX +
            (particle.x - particle.previousX) *
                (rect.bottom - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.left - particle.collisionRadius &&
            intersect <= rect.right + particle.collisionRadius) {
          particle.velY = -particle.velY * bounce;
          particle.y += 2 * (rect.bottom - position);
          collision = true;
        }
      } else if (previousPosition >= rect.top && position < rect.top) {
        intersect = particle.previousX +
            (particle.x - particle.previousX) *
                (rect.top - previousPosition) /
                (position - previousPosition);
        if (intersect >= rect.left - particle.collisionRadius &&
            intersect <= rect.right + particle.collisionRadius) {
          particle.velY = -particle.velY * bounce;
          particle.y += 2 * (rect.top - position);
          collision = true;
        }
      }
    }

    return collision;
  }
}
