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

/// The PointZone zone defines a zone which contains a single point.
class PointZone implements Zone {
  /// The point that is the zone.
  Point<double> point;

  /// The constructor defines a PointZone zone.
  ///
  /// @param point The point that is the zone.
  PointZone(this.point);

  /// The contains method determines whether a point is inside the zone.
  /// This method is used by the initializers and actions that
  /// use the zone. Usually, it need not be called directly by the user.
  ///
  /// @param x The x coordinate of the location to test for.
  /// @param y The y coordinate of the location to test for.
  /// @return true if point is inside the zone, false if it is outside.
  bool contains(double x, double y) {
    return point.x == x && point.y == y;
  }

  /// The getLocation method returns a random point inside the zone.
  /// This method is used by the initializers and actions that
  /// use the zone. Usually, it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  Point<double> getLocation() {
    return point;
  }

  /// The getArea method returns the size of the zone.
  /// This method is used by the MultiZone class. Usually,
  /// it need not be called directly by the user.
  ///
  /// @return a random point inside the zone.
  double getArea() {
    // treat as one pixel square
    return 1;
  }

  /// Manages collisions between a particle and the zone. Particles will colide with the point defined
  /// for this zone. The collisionRadius of the particle is used when calculating the collision.
  ///
  /// @param particle The particle to be tested for collision with the zone.
  /// @param bounce The coefficient of restitution for the collision.
  ///
  /// @return Whether a collision occured.
  bool collideParticle(Particle particle, [double bounce = 1]) {
    double relativePreviousX = particle.previousX - point.x;
    double relativePreviousY = particle.previousY - point.y;
    double dot =
        relativePreviousX * particle.velX + relativePreviousY * particle.velY;
    if (dot >= 0) {
      return false;
    }
    double relativeX = particle.x - point.x;
    double relativeY = particle.y - point.y;
    double radius = particle.collisionRadius;
    dot = relativeX * particle.velX + relativeY * particle.velY;
    if (dot <= 0) {
      if (relativeX > radius || relativeX < -radius) {
        return false;
      }
      if (relativeY > radius || relativeY < -radius) {
        return false;
      }
      if (relativeX * relativeX + relativeY * relativeY > radius * radius) {
        return false;
      }
    }

    double frameVelX = relativeX - relativePreviousX;
    double frameVelY = relativeY - relativePreviousY;
    double a = frameVelX * frameVelX + frameVelY * frameVelY;
    double b =
        2 * (relativePreviousX * frameVelX + relativePreviousY * frameVelY);
    double c = relativePreviousX * relativePreviousX +
        relativePreviousY * relativePreviousY -
        radius * radius;
    double sq = b * b - 4 * a * c;
    if (sq < 0) {
      return false;
    }
    double srt = sqrt(sq);
    double t1 = (-b + srt) / (2 * a);
    double t2 = (-b - srt) / (2 * a);
    final t = <double>[];

    if (t1 > 0 && t1 <= 1) {
      t.add(t1);
    }
    if (t2 > 0 && t2 <= 1) {
      t.add(t2);
    }
    double time;
    if (t.length == 0) {
      return false;
    }
    if (t.length == 1) {
      time = t[0];
    } else {
      time = min(t1, t2);
    }
    double cx = relativePreviousX + time * frameVelX + point.x;
    double cy = relativePreviousY + time * frameVelY + point.y;
    double nx = cx - point.x;
    double ny = cy - point.y;
    double d = sqrt(nx * nx + ny * ny);
    nx /= d;
    ny /= d;
    double n = frameVelX * nx + frameVelY * ny;
    frameVelX -= 2 * nx * n;
    frameVelY -= 2 * ny * n;
    particle.x = cx + (1 - time) * frameVelX;
    particle.y = cy + (1 - time) * frameVelY;
    double normalVel = particle.velX * nx + particle.velY * ny;
    particle.velX -= (1 + bounce) * nx * normalVel;
    particle.velY -= (1 + bounce) * ny * normalVel;
    return true;
  }
}
